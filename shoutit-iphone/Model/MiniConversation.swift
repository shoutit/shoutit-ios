//
//  MiniConversation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct MiniConversation: ConversationInterface {
    public let id: String
    public let typeString: String
    public let unreadMessagesCount: Int
    public let display: ConversationDescription
    public let creator: MiniProfile?
    public let modifiedAt: Int?
}

extension MiniConversation: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        typeString = try decoder.decode("type")
        unreadMessagesCount = try decoder.decode("unread_messages_count")
        display = try decoder.decode("display")
        creator = try decoder.decode("creator")
        modifiedAt = try decoder.decode("modified_at")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(typeString, key: "type")
            try encoder.encode(unreadMessagesCount, key: "unread_messages_count")
            try encoder.encode(display, key: "display")
            try encoder.encode(creator, key: "creator")
            try encoder.encode(modifiedAt, key: "modified_at")
        })
    }
}
