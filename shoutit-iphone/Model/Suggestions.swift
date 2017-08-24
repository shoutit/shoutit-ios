//
//  Suggestions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Suggestions {
    public let users: [Profile]?
    public let pages: [Profile]?
    public let tags: [Tag]?
    
    public init(users: [Profile]?, pages: [Profile]?, tags: [Tag]?) {
        self.users = users
        self.pages = pages
        self.tags = tags
    }
}

extension Suggestions: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        users = try decoder.decode("users")
        pages = try decoder.decode("pages")
        tags = try decoder.decode("tags")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(users, key: "users")
            try encoder.encode(pages, key: "pages")
            try encoder.encode(tags, key: "tags")
        })
    }
}
