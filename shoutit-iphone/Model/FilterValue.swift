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

struct FilterValue: Hashable, Equatable {
    let name: String
    let value: String
    
    var hashValue: Int {
        get {
            return self.value.hashValue
        }
    }
}

extension FilterValue: Decodable {
    
    static func decode(j: JSON) -> Decoded<FilterValue> {
        return curry(FilterValue.init)
            <^> j <| "name"
            <*> j <| "value"
    }
}

func ==(lhs: FilterValue, rhs: FilterValue) -> Bool {
    return lhs.value == rhs.value
}
