//
//  FilterValue.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

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

extension FilterValue: Decodable {
    
    public static func decode(j: JSON) -> Decoded<FilterValue> {
        return curry(FilterValue.init)
            <^> j <| "name"
            <*> j <| "slug"
            <*> j <| "id"
    }
}

public func ==(lhs: FilterValue, rhs: FilterValue) -> Bool {
    return lhs.slug == rhs.slug
}

extension FilterValue: Encodable {
    public func encode() -> JSON {
        return JSON.Object(["slug": slug.encode()])
    }
}