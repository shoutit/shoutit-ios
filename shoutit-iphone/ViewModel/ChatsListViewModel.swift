//
//  ChatsListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Pusher

protocol ChatsListViewModel {
    var pager: Pager<ConversationPagedResults, Conversation, Conversation> { get }
}

extension ChatsListViewModel {
    
    func handlePusherEvent(event: PTPusherEvent) {
        
        guard event.eventType() == .NewMessage else { return }
        guard let message : Message = event.object() else { return }
        let result = pager.findItemWithComparisonBlock {$0.id == message.conversationId}
        if let (index, conversation) = result {
            let updatedConversation = conversation.copyWithLastMessage(message)
            do {
                try pager.replaceItemAtIndex(index, withItem: updatedConversation)
            } catch {
                pager.refreshContent()
            }
        } else {
            pager.refreshContent()
        }
    }
}
