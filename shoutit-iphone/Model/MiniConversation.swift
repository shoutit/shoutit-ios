//
//  MiniConversation.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct MiniConversation: ConversationInterface {
    public let id: String
    public let typeString: String
    public let unreadMessagesCount: Int
    public let display: ConversationDescription
    public let creator: MiniProfile?
    public let modifiedAt: Int?
}

extension MiniConversation: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<MiniConversation> {
        let a = curry(MiniConversation.init)
            <^> j <| "id"
            <*> j <| "type"
            <*> j <| "unread_messages_count"
        return a
            <*> j <| "display"
            <*> j <|? "creator"
            <*> j <|? "modified_at"
    }
}
