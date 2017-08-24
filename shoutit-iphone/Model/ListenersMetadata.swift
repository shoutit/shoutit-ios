//
//  ListenersMetadata.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct ListenersMetadata {
    public let pages: Int
    public let users: Int
    public let tags: Int
    
    public init(pages: Int, users: Int, tags: Int) {
        self.pages = pages
        self.users = users
        self.tags = tags
    }
}

extension ListenersMetadata: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        pages = try decoder.decode("pages")
        users = try decoder.decode("name")
        tags = try decoder.decode("tags")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(pages, key: "pages")
            try encoder.encode(users, key: "users")
            try encoder.encode(tags, key: "tags")
        })
    }
}


extension ListenersMetadata: Equatable {}
public func ==(lhs: ListenersMetadata, rhs: ListenersMetadata) -> Bool {
    return lhs.pages == rhs.pages && lhs.users == rhs.users && lhs.tags == rhs.tags
}
