//
//  FilterValue.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct FilterValue: Hashable, Equatable {
    public let name: String
    public let slug: String
    public let id: String
    
    public var hashValue: Int {
        get {
            return slug.hashValue
        }
    }
}

extension FilterValue: JSONCodable {
    

    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        slug = try decoder.decode("slug")
        id = try decoder.decode("id")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(slug, key: "slug")
            try encoder.encode(id, key: "id")
        })
    }
}

public func ==(lhs: FilterValue, rhs: FilterValue) -> Bool {
    return lhs.slug == rhs.slug
}
