//
//  Filter.swift
//  shoutit-iphone
//
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Filter: Hashable, Equatable {
    let name: String?
    let slug: String
    let values: [FilterValue]?
    let value: FilterValue?
    
    var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension Filter: Decodable {
    
    static func decode(j: JSON) -> Decoded<Filter> {
        
        let f = curry(Filter.init)
            <^> j <|? "name"
            <*> j <| "slug"
            <*> j <||? "values"
        return f
            <*> j <|? "value"
    }
}

func ==(lhs: Filter, rhs: Filter) -> Bool {
    return lhs.slug == rhs.slug
}