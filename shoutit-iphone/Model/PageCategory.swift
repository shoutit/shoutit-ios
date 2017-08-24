//
//  PageCategory.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct PageCategory: Hashable, Equatable {
    public let name: String
    public let icon: String?
    public let image: String?
    public let slug: String
    public let children: [PageCategory]?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension PageCategory: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        icon = try decoder.decode("icon")
        image = try decoder.decode("image")
        slug = try decoder.decode("slug")
        children = try decoder.decode("children")
    }
    
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(slug, key: "slug")
        })
    }
}

public func ==(lhs: PageCategory, rhs: PageCategory) -> Bool {
    return lhs.slug == rhs.slug
}
