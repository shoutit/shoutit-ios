//
//  FilterResult.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Ogra

public struct FilterResult {
    public let filter : Filter
    public let value : FilterValue
    
    public init(filter: Filter, value: FilterValue) {
        self.filter = filter
        self.value = value
    }
}

extension FilterResult: Encodable {
    public func encode() -> JSON {
        return JSON.Object(["slug": filter.slug.encode(),
                            "value": value.encode()])
    }
}