
//
//  ConversationViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

enum ConversationDataState : Int {
    case NotLoaded
    case RestLoaded
    case PusherLoaded
}

protocol ConversationPresenter: class {
    func showSendingError(error: ErrorType) -> Void
}

final class ConversationViewModel {
    
    enum ConversationExistance {
        case Created(conversation: MiniConversation)
        case CreatedAndLoaded(conversation: Conversation)
        case NotCreated(type: ConversationType, user: Profile, aboutShout: Shout?)
        
        var shout: Shout? {
            switch self {
            case .Created:
                return nil
            case .CreatedAndLoaded(let conversation):
                return conversation.shout
            case .NotCreated(_, _, let aboutShout):
                return aboutShout
            }
        }
        
        var conversationInterface: ConversationInterface? {
            switch self {
            case .CreatedAndLoaded(let conversation): return conversation
            case .Created(let conversation): return conversation
            default: return nil
            }
        }
        
        var conversationId : String? {
            return conversationInterface?.id
        }
    }
    
    let conversation: Variable<ConversationExistance>
    
    
    
    let messages : Variable<[NSDate:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    let typingUsers : PublishSubject<TypingInfo?> = PublishSubject()
    let nowTyping : PublishSubject<Bool> = PublishSubject()
    let loadMoreState = Variable(LoadMoreState.NotReady)
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let sendingMessages : Variable<[Message]> = Variable([])
    var nextPageParams : String?
    
    private weak var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    private var socketsBag : DisposeBag?
    private var socketsConnected = false
    
    init(conversation: ConversationExistance, delegate: ConversationPresenter? = nil) {
        self.conversation = Variable(conversation)
        self.delegate = delegate
    }
    
    func createSocketObservable() {
        guard let conversation = conversation.value.conversationInterface else { return }
        if socketsConnected { return }
        socketsConnected = true
        socketsBag = DisposeBag()
        // handle presence/typing/join/left
        Account.sharedInstance.pusherManager.conversationObservable(conversation).subscribeNext { (event) -> Void in
            if event.eventType() == .UserTyping {
                if let user : TypingInfo = event.object() {
                    self.typingUsers.onNext(user)
                }
            }
            if event.eventType() == .NewMessage {
                if let msg : Message = event.object() {
                    self.appendMessages([msg])
                    
                    APIChatsService
                        .markMessageAsRead(msg)
                        .subscribeNext{}
                        .addDisposableTo(self.disposeBag)
                }
            }
            if event.eventType() == .ConversationUpdate {
                if let conversation: Conversation = event.object() {
                    self.conversation.value = .CreatedAndLoaded(conversation: conversation)
                }
            }
        }.addDisposableTo(socketsBag!)
    }
    
    func unsubscribeSockets() {
        socketsBag = nil
        socketsConnected = false
    }
    
    
    private func createConversation(message: Message) {
        guard case .NotCreated(_, let user, let shout) = conversation.value else { return }
        self.addToSending(message)
        let observable: Observable<Message>
        if let shout = shout {
            observable = APIChatsService.startConversationAboutShout(shout, message: message)
        } else {
            observable = APIChatsService.startConversationWithUsername(user.username, message: message)
        }
        observable
            .flatMapFirst { (message) -> Observable<(Conversation, Message)> in
                let fetchConversationObservable = APIChatsService.conversationWithId(message.conversationId!)
                return Observable.zip(fetchConversationObservable, Observable.just(message)) { ($0, $1) }
            }
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let conversation, _):
                    self?.conversation.value = .CreatedAndLoaded(conversation: conversation)
                    self?.fetchMessages()
                    self?.removeFromSending(message)
                case .Error(let error):
                    debugPrint(error)
                    self?.removeFromSending(message)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func deleteConversation() -> Observable<Void> {
        switch conversation.value {
        case .NotCreated: return Observable.empty()
        case .Created(let conversation): return APIChatsService.deleteConversationWithId(conversation.id)
        case .CreatedAndLoaded(let conversation): return APIChatsService.deleteConversationWithId(conversation.id)
        }
    }
    
    func fetchMessages() {
        guard let conversation = conversation.value.conversationInterface else { return }
        APIChatsService.getMessagesForConversationWithId(conversation.id).subscribeNext {[weak self] (response) -> Void in
            let messages : [Message] = response.results
            
            self?.nextPageParams = response.beforeParamsString()
            self?.appendMessages(messages)
            if messages.count > 0 {
                self?.loadMoreState.value = .ReadyToLoad
            }
        }.addDisposableTo(disposeBag)
        
        createSocketObservable()
        registerForTyping()
    }
    
    func fetchFullConversation() {
        guard case .Created(let conversation) = self.conversation.value else { return }
        APIChatsService.conversationWithId(conversation.id)
            .subscribeNext {[weak self] (conversation) in
                self?.conversation.value = .CreatedAndLoaded(conversation: conversation)
            }
            .addDisposableTo(disposeBag)
    }
    
    func registerForTyping() {
        guard let conversation = conversation.value.conversationInterface else { return }
        nowTyping.asObservable()
            .window(timeSpan: 3, count: 10000, scheduler: MainScheduler.instance)
            .flatMapLatest({ (obs) -> Observable<Bool> in
                return obs.take(1)
            })
            .subscribeNext { _ in
                Account.sharedInstance.pusherManager.sendTypingEventToConversation(conversation)
            }.addDisposableTo(disposeBag)
    }
    
    func triggerLoadMore() {
        guard let conversation = conversation.value.conversationInterface else { return }
        loadMoreState.value = .Loading
        if sortedMessages.last != nil {
            APIChatsService.moreMessagesForConversationWithId(conversation.id, nextPageParams:  self.nextPageParams)
                .subscribe(onNext: { [weak self] (response) -> Void in
                    let messages : [Message] = response.results
                    
                    self?.appendMessages(messages)
                    if messages.count > 0 {
                        self?.loadMoreState.value = .ReadyToLoad
                        self?.nextPageParams = response.beforeParamsString()
                    } else {
                        self?.loadMoreState.value = .NoMore
                        self?.nextPageParams = nil
                    }
                }, onError: { [weak self] (error) -> Void in
                    self?.loadMoreState.value = .ReadyToLoad
                }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        } else {
            loadMoreState.value = .NoMore
        }
    }
    
    func appendMessages(newMessages: [Message]) {
        var base: [Message] = []
        
        for (_, msgs) in messages.value {
            base.appendContentsOf(msgs)
        }
        
        base.appendContentsOf(newMessages)
        
        base = base.unique().sort({ (msg, msg2) -> Bool in
            return msg.createdAt > msg2.createdAt
        })
        
        sortedMessages = base
        
        let result = base.categorise { $0.day() }
        
        self.messages.value = result
    }
    
    func cellIdentifierAtIndexPath(indexPath: NSIndexPath) -> String {
        let msg = messageAtIndexPath(indexPath)
        return cellIdentifierForMessage(msg)
    }
    
    func cellIdentifierForMessage(msg: Message) -> String {
        if msg.user == nil {
            return ConversationCellIdentifier.special
        }
        
        let isOugoingMessage: Bool
        if let currentUserId = Account.sharedInstance.user?.id {
            isOugoingMessage = msg.isOutgoing(forUserWithId: currentUserId)
        } else {
            isOugoingMessage = false
        }
        
        switch msg.attachment()?.type() {
        case .None:
            return isOugoingMessage ? ConversationCellIdentifier.Text.outgoing : ConversationCellIdentifier.Text.incoming
        case .Some(.ImageAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Picture.outgoing : ConversationCellIdentifier.Picture.incoming
        case .Some(.VideoAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Video.outgoing : ConversationCellIdentifier.Video.incoming
        case .Some(.LocationAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Location.outgoing : ConversationCellIdentifier.Location.incoming
        case .Some(.ShoutAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Shout.outgoing : ConversationCellIdentifier.Shout.incoming
        case .Some(.ProfileAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Profile.outgoing : ConversationCellIdentifier.Profile.incoming
        }
    }
    
    func previousMessageFor(message: Message) -> Message? {
        guard let idx = sortedMessages.indexOf(message) else {
            return nil
        }
        
        if idx + 1 < sortedMessages.count {
            return sortedMessages[idx+1]
        }
        
        return nil
    }
    
    func messageAtIndexPath(indexPath: NSIndexPath) -> Message {
        guard let day = sortedDays()[indexPath.section] as NSDate? else {
            fatalError("No Message at Given Index")
        }
        
        guard let messagesFromGivenDay : [Message] = self.messages.value[day] else {
            fatalError("No Message at Given Index")
        }
        
        return messagesFromGivenDay[indexPath.row]
    }
    
    func sortedDays() -> [NSDate] {
        let base : [NSDate] = Array(self.messages.value.keys)
        
        return base.sort({ (first, second) -> Bool in
            return first.compare(second) == .OrderedDescending
        })
    }
    
    func sendTypingEvent() {
        self.nowTyping.onNext(true)
    }
    
    func sectionTitle(section: Int) -> String? {
        let date : NSDate = sortedDays()[section]
        return DateFormatters.sharedInstance.stringFromDate(date)
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if let day = sortedDays()[section] as NSDate?, messagesFromGivenDay : [Message] = self.messages.value[day] {
            return messagesFromGivenDay.count
        }
        
        return 0
    }
    
    func sendMessageWithText(text: String) -> Bool {
        if text.characters.count < 1 {
            return false
        }
        
        let msg = Message.messageWithText(text)
        
        guard let conversation = conversation.value.conversationInterface else {
            createConversation(msg)
            return true
        }
        
        self.addToSending(msg)
        
        APIChatsService.replyWithMessage(msg, onConversationWithId: conversation.id)
            .subscribe(onNext: { [weak self] (message) -> Void in
                self?.appendMessages([message])
                self?.removeFromSending(msg)
            }, onError: { [weak self] (error) -> Void in
                self?.delegate?.showSendingError(error)
                self?.removeFromSending(msg)
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        return true
    }
    
    func sendMessageWithAttachment(attachment: MessageAttachment) -> Bool {
        let msg = Message.messageWithAttachment(attachment)
        
        guard let conversation = conversation.value.conversationInterface else {
            createConversation(msg)
            return true
        }
        
        self.addToSending(msg)
        
        APIChatsService.replyWithMessage(msg, onConversationWithId: conversation.id)
            .doOnNext{[weak self] (message) in
                guard let `self` = self else { return }
                APIChatsService
                    .conversationWithId(conversation.id)
                    .subscribeNext{ (updatedConversation) in
                        self.conversation.value = .CreatedAndLoaded(conversation: updatedConversation)
                    }
                    .addDisposableTo(self.disposeBag)
            }
            .subscribe(onNext: { [weak self] (message) -> Void in
                self?.appendMessages([message])
                self?.removeFromSending(msg)
            }, onError: { [weak self] (error) -> Void in
                self?.removeFromSending(msg)
                self?.delegate?.showSendingError(error)
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        return true
    }
    
    func removeFromSending(msg: Message) {
        var copy = self.sendingMessages.value
        copy.removeElementIfExists(msg)
        self.sendingMessages.value = copy
    }
    
    func addToSending(msg: Message) {
        var copy = self.sendingMessages.value
        copy.append(msg)
        self.sendingMessages.value = copy
    }
    
    
    func alertControllerWithTitle(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .Default, handler: nil))
        
        return alert
    }
    
    func deleteActionAlert(completion: () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Alert Title"), message: NSLocalizedString("Do you want to delete this conversation", comment: "Alert Message"), preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Conversation", comment: "Alert Option"), style: .Destructive, handler: { (alertAction) in
            self.deleteConversation().subscribe(onNext: nil, onError: { (error) in
                debugPrint(error)
                }, onCompleted: {
                    completion()
                }, onDisposed: nil).addDisposableTo(self.disposeBag)
        }))
        
        return alert
    }
}