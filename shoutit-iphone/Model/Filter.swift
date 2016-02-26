//
//  Filter.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Filter {
    let name: String?
    let slug: String
    let value: FilterValue
}

extension Filter: Decodable {
    
    static func decode(j: JSON) -> Decoded<Filter> {
        return curry(Filter.init)
            <^> j <|? "name"
            <*> j <| "slug"
            <*> j <| "value"
    }
}

struct FilterValue {
    let name: String
    let slug: String
}

extension FilterValue: Decodable {
    
    static func decode(j: JSON) -> Decoded<FilterValue> {
        return curry(FilterValue.init)
            <^> j <| "name"
            <*> j <| "slug"
    }
}
