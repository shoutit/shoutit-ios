//
//  ConversationViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

enum ConversationDataState : Int {
    case NotLoaded
    case RestLoaded
    case PusherLoaded
}

protocol ConversationPresenter {
    func showSendingError(error: ErrorType) -> Void
}

final class ConversationViewModel {
    private var conversation: Variable<Conversation>!
    
    let messages : Variable<[NSDate:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    let typingUsers : PublishSubject<TypingInfo?> = PublishSubject()
    let nowTyping : PublishSubject<Bool> = PublishSubject()
    let loadMoreState = Variable(LoadMoreState.NotReady)
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let sendingMessages : Variable<[Message]> = Variable([])
    var nextPageParams : String?
    
    private var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    private var socketsBag : DisposeBag?
    private var socketsConnected = false
    
    init(conversation: Conversation, delegate: ConversationPresenter? = nil) {
        self.conversation = Variable(conversation)
        self.delegate = delegate
    }
    
    func createSocketObservable() {
        
        if socketsConnected {
            return
        }
        
        socketsConnected = true
        
        socketsBag = DisposeBag()
        // handle presence/typing/join/left
        Account.sharedInstance.pusherManager.conversationObservable(self.conversation.value).subscribeNext { (event) -> Void in
            if event.eventType() == .UserTyping {
                if let user : TypingInfo = event.object() {
                    self.typingUsers.onNext(user)
                }
            }
            
            if event.eventType() == .NewMessage {
                if let msg : Message = event.object() {
                    self.appendMessages([msg])
                    
                    APIChatsService.markMessageAsRead(msg).subscribeNext {
                        
                    }.addDisposableTo(self.disposeBag)
                    
                }
            }
        }.addDisposableTo(socketsBag!)
    }
    
    func unsubscribeSockets() {
        socketsBag = nil
        socketsConnected = false
    }
    
    
    func createConversation(message: Message) {
        
        self.addToSending(message)
        
        if let shout = self.conversation.value.shout {
            createConversationAboutShout(shout, message: message)
            return
        }
        
        guard let username = self.conversation.value.users?.first?.value.username else {
            debugPrint("could not create conversation without username")
            return
        }
        
        createConversationWithUsername(username, message: message)
    }
    
    func createConversationAboutShout(shout: Shout, message: Message) {
        APIChatsService.startConversationAboutShout(shout, message: message).subscribe(onNext: { [weak self] (msg) -> Void in
            let newConversation = Conversation(id: msg.conversationId!, createdAt: 0, modifiedAt: nil, apiPath: nil, webPath: nil, typeString: "chat", users: self?.conversation.value.users ?? [], lastMessage: msg, unreadMessagesCount: 0, shout: self?.conversation.value.shout, readby: self?.conversation.value.readby, display: ConversationDescription(title: nil, subtitle: nil, image: nil), subject: nil, blocked: [], admins: [])
            self?.conversation.value = newConversation
            self?.fetchMessages()
            self?.removeFromSending(message)
        }, onError: { [weak self] (error) -> Void in
            debugPrint(error)
            self?.removeFromSending(message)
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func createConversationWithUsername(username: String, message: Message) {
        APIChatsService.startConversationWithUsername(username, message: message).subscribe(onNext: { [weak self] (msg) -> Void in
            let newConversation = Conversation(id: msg.conversationId!, createdAt: 0, modifiedAt: nil, apiPath: nil, webPath: nil, typeString: "chat", users: self?.conversation.value.users ?? [], lastMessage: msg, unreadMessagesCount: 0, shout: self?.conversation.value.shout, readby: self?.conversation.value.readby, display: ConversationDescription(title: nil, subtitle: nil, image: nil), subject: nil, blocked: [], admins: [])
            self?.conversation.value = newConversation
            self?.fetchMessages()
            self?.removeFromSending(msg)
        }, onError: { [weak self] (error) -> Void in
                debugPrint(error)
                self?.removeFromSending(message)
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func deleteConversation() -> Observable<Void> {
        
        if conversation.value.id == "" {
            return Observable.empty()
        }
        
        return APIChatsService.deleteConversation(self.conversation.value)
    }
    
    func fetchMessages() {
        if self.conversation.value.id == "" {
            return
        }
        
        APIChatsService.getMessagesForConversation(self.conversation.value).subscribeNext {[weak self] (response) -> Void in
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
    
    func registerForTyping() {
        nowTyping.asObservable()
            .window(timeSpan: 3, count: 10000, scheduler: MainScheduler.instance)
            .flatMapLatest({ (obs) -> Observable<Bool> in
                return obs.take(1)
            })
            .subscribeNext { _ in
                Account.sharedInstance.pusherManager.sendTypingEventToConversation(self.conversation.value)
            }.addDisposableTo(disposeBag)

    }
    
    func triggerLoadMore() {
        loadMoreState.value = .Loading
        
        if sortedMessages.last != nil {
            APIChatsService.moreMessagesForConversation(self.conversation.value, nextPageParams:  self.nextPageParams)
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
        guard let attachmentType = msg.attachment()?.type() else {
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Text.outgoing : ConversationCellIdentifier.Text.incoming
        }
        
        switch attachmentType {
        case .ImageAttachment:
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Picture.outgoing : ConversationCellIdentifier.Picture.incoming
        case .VideoAttachment:
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Video.outgoing : ConversationCellIdentifier.Video.incoming
        case .LocationAttachment:
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Location.outgoing : ConversationCellIdentifier.Location.incoming
        case .ShoutAttachment:
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Shout.outgoing : ConversationCellIdentifier.Shout.incoming
        case .ProfileAttachment:
            return msg.isOutgoingCell() ? ConversationCellIdentifier.Profile.outgoing : ConversationCellIdentifier.Profile.incoming
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
        
        if self.conversation.value.id == "" {
            self.createConversation(msg)
            return true
        }
        
        self.addToSending(msg)
        
        APIChatsService.replyWithMessage(msg, onConversation: self.conversation.value)
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
        
        if self.conversation.value.id == "" {
            self.createConversation(msg)
            return true
        }
        
        self.addToSending(msg)
        
        APIChatsService.replyWithMessage(msg, onConversation: self.conversation.value).subscribe(onNext: { [weak self] (message) -> Void in
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
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
        
        return alert
    }
    
    func deleteActionAlert(completion: () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: NSLocalizedString("Do you want to delete this conversation", comment: ""), preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Conversation", comment: ""), style: .Destructive, handler: { (alertAction) in
            self.deleteConversation().subscribe(onNext: nil, onError: { (error) in
                debugPrint(error)
                }, onCompleted: {
                    completion()
                }, onDisposed: nil).addDisposableTo(self.disposeBag)
        }))
        
        return alert
    }
}