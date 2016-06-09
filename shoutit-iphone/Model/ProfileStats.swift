//
//  Stats.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

import Ogra

public struct ProfileStats {
    public let unreadConversationCount: Int
    public let unreadNotificationsCount: Int
}

extension ProfileStats: Decodable {
    
    public static func decode(j: JSON) -> Decoded<ProfileStats> {
        return curry(ProfileStats.init)
            <^> j <| "unread_conversations_count"
            <*> j <| "unread_notifications_count"
    }
}

extension ProfileStats: Encodable {
    public func encode() -> JSON {
        return JSON.Object([
            "unread_conversations_count" : self.unreadConversationCount.encode(),
            "unread_notifications_count" : self.unreadNotificationsCount.encode()])
    }
}
