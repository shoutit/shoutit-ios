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
    
    func subscribeToEventsWithMessageHandler (messageHandler: eventReceived, typingHandler: eventReceived, joined_chatHandler: eventReceived, left_chatHandler: eventReceived) {
        if let conversationID = self.conversationID {
            let channelName = String(format: "presence-c-%@", arguments: [conversationID])
            self.channel_new_message = SHPusherManager.sharedInstance.subscribeToEventsChannelName(channelName, eventName: "new_message", handler: messageHandler)
            let channel_name1 = String(format: "c-%@", arguments: [conversationID])
            self.channel_typing = SHPusherManager.sharedInstance.client?.subscribeToPresenceChannelNamed(channel_name1)
            self.channel_typing?.bindToEventNamed("client-user_is_typing", handleWithBlock: { (channelEvent) -> Void in
                if let data = channelEvent.data as? Dictionary<String, String> {
                    typingHandler(event: data)
                }
            })
            self.channel_joined_chat = SHPusherManager.sharedInstance.subscribeToEventsChannelName(channelName, eventName: "joined_chat", handler: joined_chatHandler)
            self.channel_left_chat = SHPusherManager.sharedInstance.subscribeToEventsChannelName(channelName, eventName: "left_chat", handler: left_chatHandler)
        }
    }
    
    func sendTyping(user: SHUser) {
        self.channel_typing?.triggerEventNamed("client-user_is_typing", data: user)
    }
    
    func whoIsOnline () -> Int {
        if let newMessage = self.channel_new_message {
            if(newMessage.isKindOfClass(PTPusherPresenceChannel)) {
                if let members = (newMessage as? PTPusherPresenceChannel)?.members {
                    return members.count
                }
            }
        }
        return 0
    }
}
