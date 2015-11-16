//
//  SHTagMeta.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHTagMeta: Mappable {

    private(set) var count: Int = 0
    private(set) var next = String()
    private(set) var previous = String()
    private(set) var results: [SHTag] = []

    required init?(_ map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        count           <- map["count"]
        next            <- map["next"]
        previous        <- map["previous"]
        results         <- map["results"]
    }
}
