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
    
    // basic fields
    let id: String
    let name: String
    let apiPath: String
    let imagePath: String?
    
    // extended fiedlds
    let webPath: String?
    let listenersCount: Int?
    let listenersPath: String?
    let isListening: Bool?
    let shoutsPath: String?
}

extension Tag: Decodable {
    
    static func decode(j: JSON) -> Decoded<Tag> {
        let a = curry(Tag.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <| "api_url"
            <*> j <|? "image"
        let b = a
            <*> j <|? "web_path"
            <*> j <|? "listeners_count"
            <*> j <|? "listeners_url"
        return b
            <*> j <|? "is_listening"
            <*> j <|? "shouts_url"
    }
}