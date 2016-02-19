//
//  Tag.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Tag {
    let id: String
    let name: String
    let apiPath: String
    let imagePath: String?
}

extension Tag: Decodable {
    
    static func decode(j: JSON) -> Decoded<Tag> {
        return curry(Tag.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <| "api_url"
            <*> j <|? "image"
    }
}