//
//  ConversationDescription.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

import Argo
import Curry
import Ogra

struct ConversationDescription {
    
    let title: String?
    let subtitle: String?
    let image: String?
}


extension ConversationDescription: Decodable {
    
    static func decode(j: JSON) -> Decoded<ConversationDescription> {
        let f = curry(ConversationDescription.init)
            <^> j <|? "title"
            <*> j <|? "sub_title"
            <*> j <|? "image"
        return f
    }
}

extension ConversationDescription: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "title"    : self.title.encode(),
            "sub_title"  : self.subtitle.encode(),
            "image" : self.image.encode()
            ])
    }
}
