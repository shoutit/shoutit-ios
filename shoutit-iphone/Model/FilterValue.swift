//
//  FilterValue.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct FilterValue: Hashable, Equatable {
    let name: String
    let slug: String
    
    var hashValue: Int {
        get {
            return slug.hashValue
        }
    }
}

extension FilterValue: Decodable {
    
    static func decode(j: JSON) -> Decoded<FilterValue> {
        return curry(FilterValue.init)
            <^> j <| "name"
            <*> j <| "slug"
    }
}

func ==(lhs: FilterValue, rhs: FilterValue) -> Bool {
    return lhs.slug == rhs.slug
}

extension FilterValue: Encodable {
    func encode() -> JSON {
        return JSON.Object(["slug": slug.encode()])
    }
}