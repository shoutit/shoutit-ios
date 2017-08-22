//
//  Tag.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct Tag {
    
    // basic fields
    public let id: String
    public let slug: String
    public let name: String
    public let apiPath: String
    public let imagePath: String?
    
    // extended fiedlds
    public let webPath: String?
    public let listenersCount: Int?
    public let listenersPath: String?
    public let isListening: Bool?
    public let shoutsPath: String?
}

extension Tag: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<Tag> {
        let a = curry(Tag.init)
            <^> j <| "id"
            <*> j <| "slug"
            <*> j <| "name"
            <*> j <| "api_url"
        let b = a
            <*> j <|? "image"
            <*> j <|? "web_path"
            <*> j <|? "listeners_count"
        return b
            <*> j <|? "listeners_url"
            <*> j <|? "is_listening"
            <*> j <|? "shouts_url"
    }
}

extension Tag {
    public func copyWithListnersCount(_ newListnersCount: Int, isListening: Bool? = nil) -> Tag {
        return Tag(id: self.id, slug: self.slug, name: self.name, apiPath: self.apiPath, imagePath: self.imagePath, webPath: self.webPath, listenersCount: newListnersCount, listenersPath: self.listenersPath, isListening: isListening != nil ? isListening : self.isListening, shoutsPath: self.shoutsPath)
    }
}
