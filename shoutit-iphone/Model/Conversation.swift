//
//  Conversation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Conversation: Decodable, Hashable, Equatable {
    let id: String
    let createdAt: Int
    let modifiedAt: Int
    let apiPath: String?
    let webPath: String?
    let typeString: String
    let users: [Profile]?
    let lastMessage: Message?
 
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Conversation> {
        let a = curry(Conversation.init)
            <^> j <| "id"
            <*> j <| "created_at"
            <*> j <| "modified_at"
        
        let b = a
            <*> j <|? "api_url"
            <*> j <|? "web_url"
            <*> j <| "type"
        
        let c = b
            <*> j <||? "users"
            <*> j <|? "last_message"
        
        return c
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id
}

extension Conversation {
    func participantsText() -> String? {
        var names : [String] = []
        
        self.users?.each({ (profile) -> () in
            names.append(profile.firstName)
        })
        
        return names.joinWithSeparator(", ")
    }
}