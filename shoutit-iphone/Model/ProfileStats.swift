//
//  Stats.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct ProfileStats {
    let unreadConversationCount: Int
    let unreadNotificationsCount: Int
    let credit: Int
}

extension ProfileStats: Decodable {
    
    static func decode(j: JSON) -> Decoded<ProfileStats> {
        return curry(ProfileStats.init)
            <^> j <| "unread_conversations_count"
            <*> j <| "unread_notifications_count"
            <*> j <| "credit"
    }
}

extension ProfileStats: Encodable {
    func encode() -> JSON {
        return JSON.Object([
            "unread_conversations_count" : self.unreadConversationCount.encode(),
            "unread_notifications_count" : self.unreadNotificationsCount.encode(),
            "credit" : self.credit.encode()])
    }
}
