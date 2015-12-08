//
//  SHConversationPusherManager.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Pusher

class SHConversationPusherManager: NSObject {
    var conversationID: String?
    var channel_new_message: PTPusherChannel?
    var channel_typing: PTPusherPresenceChannel?
    var channel_joined_chat: PTPusherChannel?
    var channel_left_chat: PTPusherChannel?
    
    func unbindAll () {
        self.channel_new_message?.unsubscribe()
        self.channel_typing?.unsubscribe()
        self.channel_left_chat?.unsubscribe()
        self.channel_joined_chat?.unsubscribe()
    }
}
