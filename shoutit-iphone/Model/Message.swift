//
//  Message.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra
import Pusher

struct Message: Decodable, Hashable, Equatable {
    
    let id: String
    let conversationId: String?
    let createdAt: Int
    let readPath: String?
    let user: Profile?
    let text: String?
    let attachments: [MessageAttachment]?
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Message> {
        let a = curry(Message.init)
            <^> j <| "id"
            <*> j <|? "conversation_id"
            <*> j <| "created_at"
            <*> j <|? "read_url"
        let b = a
            <*> j <|? "user"
            <*> j <|? "text"
            <*> j <||? "attachments"
        
        return b
    }
    
    static func messageWithText(text: String) -> Message {
        return Message(id: "", conversationId: nil, createdAt: 0, readPath: nil, user: nil, text: text, attachments: nil)
    }
    
    static func messageWithAttachment(attachment: MessageAttachment) -> Message {
        return Message(id: "", conversationId: nil, createdAt: 0, readPath: nil, user: nil, text: nil, attachments: [attachment])
    }
    
}

extension Message {
    func dateString() -> String {
        return DateFormatters.sharedInstance.stringFromDateEpoch(self.createdAt)
    }
    
    func day() -> NSDate {
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let comps = NSCalendar.currentCalendar().components(unitFlags, fromDate: NSDate(timeIntervalSince1970: NSTimeInterval(self.createdAt)))
        return NSCalendar.currentCalendar().dateFromComponents(comps)!
    }
    
    func isOutgoingCell() -> Bool {
        if let user = user, currentUser = Account.sharedInstance.user {
            return user.id == currentUser.id
        }
        
        return true
    }
    
    func isSameSenderAs(message: Message?) -> Bool {
        if let user = user, secondUser = message?.user {
            return user.id == secondUser.id
        }
        
        return false
    }
    
    func attachment() -> MessageAttachment? {
        guard let attachments = attachments else {
            return nil
        }
        
        return attachments.first
    }
}


extension Message: Encodable {
    func encode() -> JSON {
        var encoded : [String: JSON] = [:]
        
        if let text = text {
            encoded["text"] = text.encode()
        }
        
        if let attachments = attachments, attachment = attachments.first {
            encoded["attachments"] = [attachment.encode()].encode()
        }
        
        return JSON.Object(encoded)
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}