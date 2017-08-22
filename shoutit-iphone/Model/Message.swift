//
//  Message.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct Message: Decodable, Hashable, Equatable {
    
    public let id: String
    public let conversationId: String?
    public let createdAt: Int
    public let readPath: String?
    public let user: Profile?
    public let text: String?
    public let attachments: [MessageAttachment]?
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    public static func decode(_ j: JSON) -> Decoded<Message> {
        let a = curry(Message.init)
            <^> j <| "id"
            <*> j <|? "conversation_id"
            <*> j <| "created_at"
            <*> j <|? "read_url"
        let b = a
            <*> j <|? "profile"
            <*> j <|? "text"
            <*> j <||? "attachments"
        
        return b
    }
    
    public static func messageWithText(_ text: String) -> Message {
        return Message(id: generateId(), conversationId: nil, createdAt: 0, readPath: nil, user: nil, text: text, attachments: nil)
    }
    
    public static func messageWithAttachment(_ attachment: MessageAttachment) -> Message {
        return Message(id: generateId(), conversationId: nil, createdAt: 0, readPath: nil, user: nil, text: nil, attachments: [attachment])
    }
    
    public static func generateId() -> String {
        return ProcessInfo.processInfo.globallyUniqueString
    }
}

extension Message {
    public func dateString() -> String {
        return DateFormatters.sharedInstance.stringFromDateEpoch(self.createdAt)
    }
    
    public func day() -> Date {
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        let comps = (Calendar.current as NSCalendar).components(unitFlags, from: Date(timeIntervalSince1970: TimeInterval(self.createdAt)))
        return Calendar.current.date(from: comps)!
    }
    
    public func isOutgoing(forUserWithId id: String) -> Bool {
        
        if let user = user {
            return user.id == id
        }
        
        return false
    }
    
    public func isSameSenderAs(_ message: Message?) -> Bool {
        if let user = user, let secondUser = message?.user {
            return user.id == secondUser.id
        }
        
        return false
    }
    
    public func attachment() -> MessageAttachment? {
        guard let attachments = attachments else {
            return nil
        }
        
        return attachments.first
    }
}


extension Message: Encodable {
    public func encode() -> JSON {
        var encoded : [String: JSON] = [:]
        
        if let text = text {
            encoded["text"] = text.encode()
        }
        
        if let attachments = attachments, let attachment = attachments.first {
            encoded["attachments"] = [attachment.encode()].encode()
        }
        
        return JSON.object(encoded)
    }
}

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}
