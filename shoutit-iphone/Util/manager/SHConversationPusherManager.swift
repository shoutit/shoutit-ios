//
//  SHConversationPusherManager.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Pusher

class SHConversationPusherManager: NSObject, PTPusherPresenceChannelDelegate {
    var conversationID: String?
    var channel_new_message: PTPusherChannel?
    var channel_typing: PTPusherPresenceChannel?
    var channel_joined_chat: PTPusherChannel?
    var channel_left_chat: PTPusherChannel?
    var members: Int?
    
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
            self.channel_typing = SHPusherManager.sharedInstance.client?.subscribeToPresenceChannelNamed(channel_name1, delegate: self)
            self.channel_typing?.bindToEventNamed("client-user_is_typing", handleWithBlock: { (channelEvent) -> Void in
                if let data = channelEvent.data as? Dictionary<String, AnyObject> {
                    typingHandler(event: data)
                }
            })
            self.channel_joined_chat = SHPusherManager.sharedInstance.subscribeToEventsChannelName(channelName, eventName: "joined_chat", handler: joined_chatHandler)
            self.channel_left_chat = SHPusherManager.sharedInstance.subscribeToEventsChannelName(channelName, eventName: "left_chat", handler: left_chatHandler)
        }
    }
    
    func sendTyping(user: SHUser) {
        let payLoad = dictionaryUser(user)
        self.channel_typing?.triggerEventNamed("client-user_is_typing", data: payLoad)
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
    
    func dictionaryUser(user: SHUser) -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        dict["id"] = user.id
        dict["first_name"] = user.firstName
        dict["last_name"] = user.lastName
        dict["image"] = user.image
        dict["web_url"] = user.webUrl
        dict["username"] = user.username
        dict["email"] = user.email
        dict["bio"] = user.bio
        dict["gender"] = user.gender
//        [self setForDictionary:dict value:@{@"all":@(self.listening_all),
//            @"users":@(self.listening_users),
//            @"tags":@(self.listening_tags)} forKey:@"listening_count"];
//       [self setForDictionary:dict value:@(self.followers_count) forKey:@"listeners_count"];
        return dict
    }
    
    func presenceChannelDidSubscribe(channel: PTPusherPresenceChannel!) {
        members = channel.members.count
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberAdded member: PTPusherChannelMember!) {
        members = channel.members.count
    }
    
    func presenceChannel(channel: PTPusherPresenceChannel!, memberRemoved member: PTPusherChannelMember!) {
        members = channel.members.count
    }
}
