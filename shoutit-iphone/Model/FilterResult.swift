//
//  FilterResult.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Curry
import Ogra

struct FilterResult {
    let filter : Filter
    let value : FilterValue
}

extension FilterResult: Encodable {
    func encode() -> JSON {
        return JSON.Object(["slug": filter.slug.encode(),
                            "value": value.encode()])
    }
}