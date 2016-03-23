//
//  SearchShoutsResults.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct SearchShoutsResults {
    let count: Int
    let previousPath: String?
    let nextPath: String?
    let results: [Shout]
}

extension SearchShoutsResults: Decodable {
    
    static func decode(j: JSON) -> Decoded<SearchShoutsResults> {
        let a = curry(SearchShoutsResults.init)
            <^> j <| "count"
            <*> j <|? "previous"
        let b = a
            <*> j <|? "next"
            <*> j <|| "results"
        return b
    }
}
