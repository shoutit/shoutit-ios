//
//  Stats.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct ProfileStats {
    public let unreadConversationCount: Int
    public let unreadNotificationsCount: Int
    public let totalUnreadCount: Int?
    public let credit: Int?
}

extension ProfileStats: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        unreadConversationCount = try decoder.decode("unread_conversations_count")
        unreadNotificationsCount = try decoder.decode("unread_notifications_count")
        totalUnreadCount = try decoder.decode("total_unread_count")
        credit = try decoder.decode("credit")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(unreadConversationCount, key: "unread_conversations_count")
            try encoder.encode(unreadNotificationsCount, key: "unread_notifications_count")
            try encoder.encode(totalUnreadCount, key: "total_unread_count")
            try encoder.encode(credit, key: "credit")
        })
    }
}
