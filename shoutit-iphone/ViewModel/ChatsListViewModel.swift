//
//  ChatsListViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Pusher
import ShoutitKit

protocol ChatsListViewModel {
    var pager: Pager<ConversationPagedResults, MiniConversation, MiniConversation> { get }
}

extension ChatsListViewModel {
    
    func handlePusherEvent(event: PTPusherEvent) {
        
        guard event.eventType() == .NewMessage else { return }
        guard let _ : Message = event.object() else { return }
        pager.refreshContent()
    }
}
