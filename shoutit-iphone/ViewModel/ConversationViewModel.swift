//
//  ConversationViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

protocol ConversationPresenter {
    func showSendingError(error: NSError) -> Void
}

class ConversationViewModel {
    private var conversation: Conversation
    
    let messages : Variable<[Message]> = Variable([])
    
    private var delegate : ConversationPresenter?
    
    private let disposeBag = DisposeBag()
    
    init(conversation: Conversation, delegate: ConversationPresenter? = nil) {
        self.conversation = conversation
        self.delegate = delegate
    }
    
    func fetchMessages() {
        APIChatsService.getMessagesForConversation(self.conversation).subscribeNext {[weak self] (messages) -> Void in
            self?.appendMessages(messages)
        }.addDisposableTo(disposeBag)
    }
    
    func handleError(error: NSError) {
        
    }
    
    func appendMessages(newMessages: [Message]) {
        var base: [Message] = []
        
        base.appendContentsOf(self.messages.value)
        base.appendContentsOf(newMessages)
        
        self.messages.value = base.unique().sort({ (msg, msg2) -> Bool in
            return msg.createdAt > msg2.createdAt
        })
        
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