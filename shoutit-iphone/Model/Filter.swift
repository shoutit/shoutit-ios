//
//  Filter.swift
//  shoutit-iphone
//
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Filter {
    let name: String?
    let slug: String
    let values: [FilterValue]?
}

extension Filter: Decodable {
    
    static func decode(j: JSON) -> Decoded<Filter> {
        return curry(Filter.init)
            <^> j <|? "name"
            <*> j <| "slug"
            <*> j <||? "values"
    }
}

