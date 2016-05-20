//
//  MiniConversation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct MiniConversation: ConversationInterface {
    let id: String
    let typeString: String
    let unreadMessagesCount: Int
    let display: ConversationDescription
    let creator: MiniProfile
    let modifiedAt: Int?
}

extension MiniConversation: Decodable {
    
    static func decode(j: JSON) -> Decoded<MiniConversation> {
        let a = curry(MiniConversation.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "unread_messages_count"
        return a
            <*> j <| "display"
            <*> j <| "creator"
            <*> j <|? "modified_at"
    }
}
