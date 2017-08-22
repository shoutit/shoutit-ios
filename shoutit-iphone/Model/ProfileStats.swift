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
    public let totalUnreadCount: Int?
    public let credit: Int?
}

extension ProfileStats: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<ProfileStats> {
        return curry(ProfileStats.init)
            <^> j <| "unread_conversations_count"
            <*> j <| "unread_notifications_count"
            <*> j <|? "total_unread_count"
            <*> j <|? "credit"
    }
}

extension ProfileStats: Encodable {
    public func encode() -> JSON {
        return JSON.object([
            "unread_conversations_count" : self.unreadConversationCount.encode(),
            "unread_notifications_count" : self.unreadNotificationsCount.encode(),
            "total_unread_count" : self.totalUnreadCount.encode(),
            "credit" : self.credit.encode()])
    }
}
