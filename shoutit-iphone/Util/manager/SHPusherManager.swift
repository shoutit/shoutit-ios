//
//  SHPusherManager.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Pusher

typealias eventReceived = (event: Dictionary<String, String>) -> ()
let PUSHER_APP_KEY = "86d676926d4afda44089"
let PUSHER_URL = "https://api.shoutit.com/v2/pusher/auth"

class SHPusherManager: NSObject, PTPusherDelegate {
    private var client: PTPusher?
    private var got_message_block: eventReceived?
    private var got_listen_block: eventReceived?
    private var message_channel: PTPusherChannel?
    private var listen_channel: PTPusherChannel?
    
    static var sharedInstance = SHPusherManager()
    
    override init() {
        super.init()
        client = PTPusher(key: PUSHER_APP_KEY, delegate: self)
        self.client?.authorizationURL = NSURL(string: PUSHER_URL)
        self.client?.connect()
    }

    
    func pusher(pusher: PTPusher!, willAuthorizeChannel channel: PTPusherChannel!, withRequest request: NSMutableURLRequest!) {
        let token = authHeaders()
        request.setValue(token, forHTTPHeaderField: "Authorization")
    }
    
    func pusher(pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        
    }
    
    func pusher(pusher: PTPusher!, didSubscribeToChannel channel: PTPusherChannel!) {
        
    }
    
    func pusher(pusher: PTPusher!, didFailToSubscribeToChannel channel: PTPusherChannel!, withError error: NSError!) {
        
    }
    
    func channelWithName (name: String) -> PTPusherChannel {
        if let channel = self.client?.subscribeToChannelNamed(name) {
            return channel
        }
        return PTPusherChannel()
    }
    
    func subscribeToEventsChannelName (channelName: String, eventName: String, handler: eventReceived) -> PTPusherChannel {
        let channel = SHPusherManager.sharedInstance.channelWithName(channelName)
        channel.bindToEventNamed(eventName) { (channelEvent) -> Void in
            if let data = channelEvent.data as? Dictionary<String, String> {
                handler(event: data)
            }
        }
        return channel
    }
    
    func sendEvent(eventName: String, data: AnyObject, channelName: String) {
        self.client?.sendEventNamed(eventName, data: data, channel: channelName)
    }
    
    func handleNewMessage(eventhandler: eventReceived) {
        self.got_message_block = eventhandler
    }
    
    func handleNewListen(eventhandler: eventReceived) {
        self.got_listen_block = eventhandler
    }
    
    func subscribeToEventsWithUserID(userID: String) {
        let channel_name = String(format: "u-%@", arguments: [userID])
        self.message_channel = self.client?.subscribeToPresenceChannelNamed(channel_name)
        self.message_channel?.bindToEventNamed("new_message", handleWithBlock: { (channelEvent) -> Void in
            if let block = self.got_message_block, let data = channelEvent.data as? Dictionary<String, String>{
                block(event: data)
            }
                
        })
        self.message_channel?.bindToEventNamed("new_listen", handleWithBlock: { (channelEvent) -> Void in
            if let block = self.got_listen_block,let data = channelEvent.data as? Dictionary<String, String> {
                block(event: data)
            }
        })
    }
    
    // Private
    private func authHeaders() -> String? {
        if let oauthToken = SHOauthToken.getFromCache(), let accessToken = oauthToken.accessToken, let tokenType = oauthToken.tokenType {
            // Headers
            return String(format: "%@ %@", arguments: [tokenType, accessToken])
        }
        return nil;
    }
}
