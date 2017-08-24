//
//  Filter.swift
//  shoutit-iphone
//
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Filter: Hashable, Equatable {
    public let name: String?
    public let slug: String
    public let values: [FilterValue]?
    public let value: FilterValue?
    public let id: String?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

public func ==(lhs: Filter, rhs: Filter) -> Bool {
    return lhs.slug == rhs.slug
}

extension Filter: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
            name = try decoder.decode("name")
            slug = try decoder.decode("slug")
            values = try decoder.decode("values")
            value = try decoder.decode("value")
            id = try decoder.decode("id")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(slug, key: "slug")
            try encoder.encode(values, key: "values")
            try encoder.encode(value, key: "value")
            try encoder.encode(id, key: "id")
        })
    }
}
