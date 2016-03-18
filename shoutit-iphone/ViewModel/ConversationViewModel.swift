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
    
    let messages : Variable<[String:[Message]]> = Variable([:])
    var sortedMessages : [Message] = []
    
    private var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    
    init(conversation: Conversation, delegate: ConversationPresenter? = nil) {
        self.conversation = conversation
        self.delegate = delegate
    }
    
    func createSocketObservable() {
        // handle presence/typing/join/left
        PusherClient.sharedInstance.conversationObservable(self.conversation).subscribeNext { (event) -> Void in
            
        }.addDisposableTo(disposeBag)
        
        // handle messages
        PusherClient.sharedInstance.mainChannelObservable()
        .filter({ (event) -> Bool in
            return event.eventType() == .NewMessage
        })
        .map({ (event) -> Message? in
            let msg : Message? = event.object()
            return msg
        })
        .filter({ [weak self] (msg) -> Bool in
            if let msg : Message = msg {
                return msg.conversationId == self?.conversation.id
            }
            return false
        })
        .subscribeNext {[weak self] (msg) -> Void in
            if let msg : Message = msg {
                self?.appendMessages([msg])
            }
        }.addDisposableTo(disposeBag)
    }
    
    func fetchMessages() {
        APIChatsService.getMessagesForConversation(self.conversation).subscribeNext {[weak self] (messages) -> Void in
            self?.appendMessages(messages)
        }.addDisposableTo(disposeBag)
        
        createSocketObservable()
    }
    
    func appendMessages(newMessages: [Message]) {
        var base: [Message] = []
        
        for (_, msgs) in messages.value {
            base.appendContentsOf(msgs)
        }
        
        base.appendContentsOf(newMessages)
        
        base = base.unique().sort({ (msg, msg2) -> Bool in
            return msg.createdAt < msg2.createdAt
        })
        
        sortedMessages = base
        
        let result = base.categorise { $0.dateString() }
        
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
        guard let day = Array(self.messages.value.keys)[indexPath.section] as String? else {
            fatalError("No Message at Given Index")
        }
        
        guard let messagesFromGivenDay : [Message] = self.messages.value[day] else {
            fatalError("No Message at Given Index")
        }
        
        return messagesFromGivenDay[indexPath.row]
    }
    
    func sectionTitle(section: Int) -> String? {
        return Array(self.messages.value.keys)[section] as String
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if let day = Array(self.messages.value.keys)[section] as String?, messagesFromGivenDay : [Message] = self.messages.value[day] {
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