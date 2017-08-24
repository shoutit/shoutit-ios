//
//  FilterResult.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import JSONCodable

public struct FilterResult {
    public let filter : Filter
    public let value : FilterValue
    
    public init(filter: Filter, value: FilterValue) {
        self.filter = filter
        self.value = value
    }
}

extension FilterResult: JSONEncodable {
  
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(filter.slug, key: "slug")
            try encoder.encode(value, key: "value")
        })
    }
}
