//
//  ConversationDescription.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Ogra

public struct ConversationDescription {
    
    public let title: String?
    public let subtitle: String?
    public let image: String?
    public let lastMessageSummary: String?
    
    public static var nilDescription: ConversationDescription {
        return ConversationDescription(title: nil, subtitle: nil, image: nil, lastMessageSummary: nil)
    }
}


extension ConversationDescription: Decodable {
    
    public static func decode(j: JSON) -> Decoded<ConversationDescription> {
        let f = curry(ConversationDescription.init)
            <^> j <|? "title"
            <*> j <|? "sub_title"
            <*> j <|? "image"
            <*> j <|? "last_message_summary"
        return f
    }
}

extension ConversationDescription: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "title"    : self.title.encode(),
            "sub_title"  : self.subtitle.encode(),
            "image" : self.image.encode()
            ])
    }
}
