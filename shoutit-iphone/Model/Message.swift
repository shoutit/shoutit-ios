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
    let createdAt: Int
    let readPath: String?
    let user: Profile?
    let text: String?
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Message> {
        let a = curry(Message.init)
            <^> j <| "id"
            <*> j <| "created_at"
            <*> j <|? "read_url"
        let b = a
            <*> j <|? "user"
            <*> j <|? "text"
        
        return b
    }
    
    static func messageWithText(text: String) -> Message {
        return Message(id: "", createdAt: 0, readPath: nil, user: nil, text: text)
    }
    
    
}

extension Message {
    func dateString() -> String {
        return DateFormatters.sharedInstance.stringFromDateEpoch(self.createdAt)
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
}


extension Message: Encodable {
    func encode() -> JSON {
        return JSON.Object(["text": (self.text ?? "").encode()])
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}