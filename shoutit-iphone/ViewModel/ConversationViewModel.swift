
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
    case notLoaded
    case restLoaded
    case pusherLoaded
}

protocol ConversationPresenter: class {
    func showSendingError(_ error: Error) -> Void
}

final class ConversationViewModel {
    
    enum ConversationExistance {
        case created(conversation: MiniConversation)
        case createdAndLoaded(conversation: Conversation)
        case notCreated(type: ConversationType, user: Profile, aboutShout: Shout?)
        
        var shout: Shout? {
            switch self {
            case .created:
                return nil
            case .createdAndLoaded(let conversation):
                return conversation.shout
            case .notCreated(_, _, let aboutShout):
                return aboutShout
            }
        }
        
        var conversationInterface: ConversationInterface? {
            switch self {
            case .createdAndLoaded(let conversation): return conversation
            case .created(let conversation): return conversation
            default: return nil
            }
        }
        
        var conversationId : String? {
            return conversationInterface?.id
        }
    }
    
    let conversation: Variable<ConversationExistance>
    
    
    
    let messages : Variable<[Date:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    let typingUsers : PublishSubject<TypingInfo?> = PublishSubject()
    let nowTyping : PublishSubject<Bool> = PublishSubject()
    let loadMoreState = Variable(LoadMoreState.notReady)
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let sendingMessages : Variable<[Message]> = Variable([])
    var nextPageParams : String?
    
    fileprivate weak var delegate : ConversationPresenter?
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var socketsBag : DisposeBag?
    fileprivate var socketsConnected = false
    
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
        Account.sharedInstance.pusherManager.conversationObservable(conversation).subscribe(onNext: { (event) -> Void in
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
                        .subscribe(onNext: {})
                        .addDisposableTo(self.disposeBag)
                }
            }
            if event.eventType() == .ConversationUpdate {
                if let conversation: Conversation = event.object() {
                    self.conversation.value = .createdAndLoaded(conversation: conversation)
                }
            }
        }).addDisposableTo(socketsBag!)
    }
    
    func unsubscribeSockets() {
        socketsBag = nil
        socketsConnected = false
    }
    
    
    fileprivate func createConversation(_ message: Message) {
        guard case .notCreated(_, let user, let shout) = conversation.value else { return }
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
                case .next(let conversation, _):
                    self?.conversation.value = .createdAndLoaded(conversation: conversation)
                    self?.fetchMessages()
                    self?.removeFromSending(message)
                case .error(let error):
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
        case .notCreated: return Observable.empty()
        case .created(let conversation): return APIChatsService.deleteConversationWithId(conversation.id)
        case .createdAndLoaded(let conversation): return APIChatsService.deleteConversationWithId(conversation.id)
        }
    }
    
    func fetchMessages() {
        guard let conversation = conversation.value.conversationInterface else { return }
        APIChatsService.getMessagesForConversationWithId(conversation.id).subscribe(onNext: {[weak self] (response) -> Void in
            let messages : [Message] = response.results
            
            self?.nextPageParams = response.beforeParamsString()
            self?.appendMessages(messages)
            if messages.count > 0 {
                self?.loadMoreState.value = .readyToLoad
            }
        }).addDisposableTo(disposeBag)
        
        createSocketObservable()
        registerForTyping()
    }
    
    func fetchFullConversation() {
        guard case .created(let conversation) = self.conversation.value else { return }
        APIChatsService.conversationWithId(conversation.id)
            .subscribe(onNext: {[weak self] (conversation) in
                self?.conversation.value = .createdAndLoaded(conversation: conversation)
            })
            .addDisposableTo(disposeBag)
    }
    
    func registerForTyping() {
        guard let conversation = conversation.value.conversationInterface else { return }
        nowTyping.asObservable()
            .window(timeSpan: 3, count: 10000, scheduler: MainScheduler.instance)
            .flatMapLatest({ (obs) -> Observable<Bool> in
                return obs.take(1)
            })
            .subscribe(onNext: { _ in
                Account.sharedInstance.pusherManager.sendTypingEventToConversation(conversation)
            }).addDisposableTo(disposeBag)
    }
    
    func triggerLoadMore() {
        guard let conversation = conversation.value.conversationInterface else { return }
        loadMoreState.value = .loading
        if sortedMessages.last != nil {
            APIChatsService.moreMessagesForConversationWithId(conversation.id, nextPageParams:  self.nextPageParams)
                .subscribe(onNext: { [weak self] (response) -> Void in
                    let messages : [Message] = response.results
                    
                    self?.appendMessages(messages)
                    if messages.count > 0 {
                        self?.loadMoreState.value = .readyToLoad
                        self?.nextPageParams = response.beforeParamsString()
                    } else {
                        self?.loadMoreState.value = .noMore
                        self?.nextPageParams = nil
                    }
                }, onError: { [weak self] (error) -> Void in
                    self?.loadMoreState.value = .readyToLoad
                }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        } else {
            loadMoreState.value = .noMore
        }
    }
    
    func appendMessages(_ newMessages: [Message]) {
        var base: [Message] = []
        
        for (_, msgs) in messages.value {
            base.append(contentsOf: msgs)
        }
        
        base.append(contentsOf: newMessages)
        
        base = base.unique().sorted(by: { (msg, msg2) -> Bool in
            return msg.createdAt > msg2.createdAt
        })
        
        sortedMessages = base
        
        let result = base.categorise { $0.day() }
        
        self.messages.value = result
    }
    
    func cellIdentifierAtIndexPath(_ indexPath: IndexPath) -> String {
        let msg = messageAtIndexPath(indexPath)
        return cellIdentifierForMessage(msg)
    }
    
    func cellIdentifierForMessage(_ msg: Message) -> String {
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
        case .none:
            return isOugoingMessage ? ConversationCellIdentifier.Text.outgoing : ConversationCellIdentifier.Text.incoming
        case .some(.imageAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Picture.outgoing : ConversationCellIdentifier.Picture.incoming
        case .some(.videoAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Video.outgoing : ConversationCellIdentifier.Video.incoming
        case .some(.locationAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Location.outgoing : ConversationCellIdentifier.Location.incoming
        case .some(.shoutAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Shout.outgoing : ConversationCellIdentifier.Shout.incoming
        case .some(.profileAttachment):
            return isOugoingMessage ? ConversationCellIdentifier.Profile.outgoing : ConversationCellIdentifier.Profile.incoming
        }
    }
    
    func previousMessageFor(_ message: Message) -> Message? {
        guard let idx = sortedMessages.index(of: message) else {
            return nil
        }
        
        if idx + 1 < sortedMessages.count {
            return sortedMessages[idx+1]
        }
        
        return nil
    }
    
    func messageAtIndexPath(_ indexPath: IndexPath) -> Message {
        guard let day = sortedDays()[indexPath.section] as Date? else {
            fatalError("No Message at Given Index")
        }
        
        guard let messagesFromGivenDay : [Message] = self.messages.value[day] else {
            fatalError("No Message at Given Index")
        }
        
        return messagesFromGivenDay[indexPath.row]
    }
    
    func sortedDays() -> [Date] {
        let base : [Date] = Array(self.messages.value.keys)
        
        return base.sorted(by: { (first, second) -> Bool in
            return first.compare(second) == .orderedDescending
        })
    }
    
    func sendTypingEvent() {
        self.nowTyping.onNext(true)
    }
    
    func sectionTitle(_ section: Int) -> String? {
        let date : Date = sortedDays()[section]
        return DateFormatters.sharedInstance.stringFromDate(date)
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if let day = sortedDays()[section] as Date?, let messagesFromGivenDay : [Message] = self.messages.value[day] {
            return messagesFromGivenDay.count
        }
        
        return 0
    }
    
    func sendMessageWithText(_ text: String) -> Bool {
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
    
    func sendMessageWithAttachment(_ attachment: MessageAttachment) -> Bool {
        let msg = Message.messageWithAttachment(attachment)
        
        guard let conversation = conversation.value.conversationInterface else {
            createConversation(msg)
            return true
        }
        
        self.addToSending(msg)
        
        APIChatsService.replyWithMessage(msg, onConversationWithId: conversation.id)
            .do(onNext: { [weak self] (message) in
                guard let `self` = self else { return }
                APIChatsService
                    .conversationWithId(conversation.id)
                    .subscribe(onNext: { (updatedConversation) in
                        self.conversation.value = .createdAndLoaded(conversation: updatedConversation)
                    })
                    .addDisposableTo(self.disposeBag)
            })
            .subscribe(onNext: { [weak self] (message) -> Void in
                self?.appendMessages([message])
                self?.removeFromSending(msg)
            }, onError: { [weak self] (error) -> Void in
                self?.removeFromSending(msg)
                self?.delegate?.showSendingError(error)
            }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
        
        return true
    }
    
    func removeFromSending(_ msg: Message) {
        var copy = self.sendingMessages.value
        copy.removeElementIfExists(msg)
        self.sendingMessages.value = copy
    }
    
    func addToSending(_ msg: Message) {
        var copy = self.sendingMessages.value
        copy.append(msg)
        self.sendingMessages.value = copy
    }
    
    
    func alertControllerWithTitle(_ title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: nil))
        
        return alert
    }
    
    func deleteActionAlert(_ completion: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Alert Title"), message: NSLocalizedString("Do you want to delete this conversation", comment: "Alert Message"), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Conversation", comment: "Alert Option"), style: .destructive, handler: { (alertAction) in
            self.deleteConversation().subscribe(onNext: nil, onError: { (error) in
                debugPrint(error)
                }, onCompleted: {
                    completion()
                }, onDisposed: nil).addDisposableTo(self.disposeBag)
        }))
        
        return alert
    }
}
