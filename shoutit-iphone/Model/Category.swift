//
//  Category.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Category: Hashable, Equatable {
    public let name: String
    public let icon: String?
    public let image: String?
    public let slug: String
    public let filters: [Filter]?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

public func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.slug == rhs.slug
}

extension Category: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        icon = try decoder.decode("icon")
        image = try decoder.decode("image")
        slug = try decoder.decode("slug")
        filters = try decoder.decode("filters")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(slug, key: "slug")
        })
    }
}
