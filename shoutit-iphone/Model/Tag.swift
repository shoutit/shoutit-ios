//
//  Tag.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

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


extension Tag {
    public func copyWithListnersCount(_ newListnersCount: Int, isListening: Bool? = nil) -> Tag {
        return Tag(id: self.id, slug: self.slug, name: self.name, apiPath: self.apiPath, imagePath: self.imagePath, webPath: self.webPath, listenersCount: newListnersCount, listenersPath: self.listenersPath, isListening: isListening != nil ? isListening : self.isListening, shoutsPath: self.shoutsPath)
    }
}

extension Tag: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        slug = try decoder.decode("slug")
        name = try decoder.decode("name")
        apiPath = try decoder.decode("api_url")
        imagePath = try decoder.decode("image")
        webPath = try decoder.decode("web_path")
        listenersCount = try decoder.decode("listeners_count")
        listenersPath = try decoder.decode("listeners_url")
        isListening = try decoder.decode("is_listening")
        shoutsPath = try decoder.decode("shouts_url")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(slug, key: "slug")
            try encoder.encode(name, key: "name")
            try encoder.encode(apiPath, key: "api_url")
            try encoder.encode(imagePath, key: "image")
            try encoder.encode(webPath, key: "web_path")
            try encoder.encode(listenersCount, key: "listeners_count")
            try encoder.encode(listenersPath, key: "listeners_url")
            try encoder.encode(isListening, key: "is_listening")
            try encoder.encode(shoutsPath, key: "shouts_url")
        })
    }
}
