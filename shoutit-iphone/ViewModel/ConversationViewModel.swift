//
//  ConversationViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

let conversationTextCellIdentifier = "conversationTextCellIdentifier"
let conversationSectionDayIdentifier = "conversationSectionDayIdentifier"
let conversationLoadMoreIdentifier = "conversationLoadMoreIdentifier"

// text cells
let conversationOutGoingTextCellIdentifier = "conversationOutGoingCell"
let conversationIncomingTextCellIdentifier = "conversationIncomingCell"

// location cells
let conversationIncomingLocationCellIdentifier = "conversationIncomingLocationCell"
let conversationOutGoingLocationCellIdentifier = "conversationOutGoingLocationCell"

// picture cells
let conversationOutGoingPictureCell = "conversationOutGoingPictureCell"
let conversationIncomingPictureCell = "conversationIncomingPictureCell"

// video cells
let conversationOutGoingVideoCell = "conversationOutGoingVideoCell"
let conversationIncomingVideoCell = "conversationIncomingVideoCell"

// shout cells
let conversationOutGoingShoutCell = "conversationOutGoingShoutCell"
let conversationIncomingShoutCell = "conversationIncomingShoutCell"

enum ConversationDataState : Int {
    case NotLoaded
    case RestLoaded
    case PusherLoaded
}

protocol ConversationPresenter {
    func showSendingError(error: NSError) -> Void
}

class ConversationViewModel {
    private var conversation: Variable<Conversation>!
    
    let messages : Variable<[NSDate:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    let typingUsers : PublishSubject<Profile?> = PublishSubject()
    let nowTyping : PublishSubject<Bool> = PublishSubject()
    let loadMoreState = Variable(LoadMoreState.NotReady)
    let presentingSubject : PublishSubject<UIViewController?> = PublishSubject()
    let sendingMessages : Variable<[Message]> = Variable([])
    
    private var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    
    init(conversation: Conversation, delegate: ConversationPresenter? = nil) {
        self.conversation = Variable(conversation)
        self.delegate = delegate
    }
    
    func createSocketObservable() {
        // handle presence/typing/join/left
        PusherClient.sharedInstance.conversationObservable(self.conversation.value).subscribeNext { (event) -> Void in
            if event.eventType() == .UserTyping {
                if let user : Profile = event.object() {
                    self.typingUsers.onNext(user)
                }
            }
        }.addDisposableTo(disposeBag)
        
        // handle messages
        PusherClient.sharedInstance.conversationMessagesObservable(self.conversation.value).subscribeNext {[weak self] (msg) -> Void in
            if let msg : Message = msg {
                self?.appendMessages([msg])
            }
        }.addDisposableTo(disposeBag)
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
            let newConversation = Conversation(id: msg.conversationId!, createdAt: 0, modifiedAt: nil, apiPath: nil, webPath: nil, typeString: "chat", users: self?.conversation.value.users ?? [], lastMessage: msg, unreadMessagesCount: 0, shout: self?.conversation.value.shout, readby: self?.conversation.value.readby)
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
            let newConversation = Conversation(id: msg.conversationId!, createdAt: 0, modifiedAt: nil, apiPath: nil, webPath: nil, typeString: "chat", users: self?.conversation.value.users ?? [], lastMessage: msg, unreadMessagesCount: 0, shout: self?.conversation.value.shout, readby: self?.conversation.value.readby)
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
        
        APIChatsService.getMessagesForConversation(self.conversation.value).subscribeNext {[weak self] (messages) -> Void in
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
                PusherClient.sharedInstance.sendTypingEventToConversation(self.conversation.value)
            }.addDisposableTo(disposeBag)

    }
    
    func triggerLoadMore() {
        loadMoreState.value = .Loading
        
        if let lastMessage = sortedMessages.last {
            APIChatsService.moreMessagesForConversation(self.conversation.value, lastMessageEpoch:  lastMessage.createdAt)
                .subscribe(onNext: { [weak self] (messages) -> Void in
                    self?.appendMessages(messages)
                    if messages.count > 0 {
                        self?.loadMoreState.value = .ReadyToLoad
                    } else {
                        self?.loadMoreState.value = .NoMore
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
        
        if let _ = msg.attachment() {
            return cellIdentifierForMessageWithAttachment(msg)
        }
        
        return msg.isOutgoingCell() ? conversationOutGoingTextCellIdentifier : conversationIncomingTextCellIdentifier
    }
    
    func cellIdentifierForMessageWithAttachment(msg: Message) -> String {
        guard let attachment = msg.attachment() else {
            fatalError("this should not happend")
        }
        
        if attachment.type() == .Location {
            return msg.isOutgoingCell() ? conversationOutGoingLocationCellIdentifier: conversationIncomingLocationCellIdentifier
        }
        
        if attachment.type() == .Image {
            return msg.isOutgoingCell() ? conversationOutGoingPictureCell : conversationIncomingPictureCell
        }
        
        if attachment.type() == .Video {
            return msg.isOutgoingCell() ? conversationOutGoingVideoCell : conversationIncomingVideoCell
        }
        
        if attachment.type() == .Shout {
            return msg.isOutgoingCell() ? conversationOutGoingShoutCell : conversationIncomingShoutCell
        }
        
        return msg.isOutgoingCell() ? conversationOutGoingTextCellIdentifier : conversationIncomingTextCellIdentifier
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
        
        APIChatsService.replyWithMessage(msg, onConversation: self.conversation.value).subscribe(onNext: { [weak self] (message) -> Void in
                self?.appendMessages([message])
                self?.removeFromSending(msg)
            }, onError: { [weak self] (error) -> Void in
                self?.delegate?.showSendingError(error as NSError)
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
                self?.delegate?.showSendingError(error as NSError)
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
    
    func moreActionAlert(completion: ((action: UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("More", comment: ""), message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("View Profile", comment: ""), style: .Default, handler: { (alertAction) in
            completion(action: alertAction)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete Conversation", comment: ""), style: .Destructive, handler: { (alertAction) in
            completion(action: alertAction)
        }))
        
        return alert
    }
}