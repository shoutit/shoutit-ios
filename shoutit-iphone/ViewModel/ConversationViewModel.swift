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
let conversationOutGoingTextCellIdentifier = "conversationOutGoingCell"
let conversationIncomingTextCellIdentifier = "conversationIncomingCell"

enum ConversationDataState : Int {
    case NotLoaded
    case RestLoaded
    case PusherLoaded
    
}

protocol ConversationPresenter {
    func showSendingError(error: NSError) -> Void
}

class ConversationViewModel {
    private var conversation: Conversation
    
    let messages : Variable<[NSDate:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    let typingUsers : PublishSubject<Profile?> = PublishSubject()
    let nowTyping : PublishSubject<Bool> = PublishSubject()
    let loadMoreState = Variable(LoadMoreState.NoMore)
    
    private var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    
    init(conversation: Conversation, delegate: ConversationPresenter? = nil) {
        self.conversation = conversation
        self.delegate = delegate
    }
    
    func createSocketObservable() {
        // handle presence/typing/join/left
        PusherClient.sharedInstance.conversationObservable(self.conversation).subscribeNext { (event) -> Void in
            if event.eventType() == .UserTyping {
                if let user : Profile = event.object() {
                    self.typingUsers.onNext(user)
                }
            }
        }.addDisposableTo(disposeBag)
        
        // handle messages
        PusherClient.sharedInstance.conversationMessagesObservable(self.conversation).subscribeNext {[weak self] (msg) -> Void in
            if let msg : Message = msg {
                self?.appendMessages([msg])
            }
        }.addDisposableTo(disposeBag)
    }
    
    func fetchMessages() {
        APIChatsService.getMessagesForConversation(self.conversation).subscribeNext {[weak self] (messages) -> Void in
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
                PusherClient.sharedInstance.sendTypingEventToConversation(self.conversation)
            }.addDisposableTo(disposeBag)

    }
    
    func triggerLoadMore() {
        loadMoreState.value = .Loading
        
        if let lastMessage = sortedMessages.last {
            APIChatsService.moreMessagesForConversation(self.conversation, lastMessageEpoch:  lastMessage.createdAt)
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
        
        if msg.isOutgoingCell() {
            return conversationOutGoingTextCellIdentifier
        }
        
        return conversationIncomingTextCellIdentifier
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
        
        APIChatsService.replyWithMessage(msg, onConversation: self.conversation).subscribe(onNext: { [weak self] (message) -> Void in
                self?.appendMessages([message])
            }, onError: { [weak self] (error) -> Void in
                self?.delegate?.showSendingError(error as NSError)
            }, onCompleted: { () -> Void in
                
            }, onDisposed: { () -> Void in
                
        }).addDisposableTo(disposeBag)
        
        return true
    }
    
    func alertControllerWithTitle(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
        
        return alert
    }
}