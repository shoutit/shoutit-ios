//
//  Filter.swift
//  shoutit-iphone
//
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct Filter: Hashable, Equatable {
    public let name: String?
    public let slug: String
    public let values: [FilterValue]?
    public let value: FilterValue?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension Filter: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Filter> {
        
        let f = curry(Filter.init)
            <^> j <|? "name"
            <*> j <| "slug"
            <*> j <||? "values"
        return f
            <*> j <|? "value"
    }
}

public func ==(lhs: Filter, rhs: Filter) -> Bool {
    return lhs.slug == rhs.slug
}