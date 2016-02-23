//
//  SHTopTagsModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import ObjectMapper

class SHDiscoverLocation: Mappable {
    
    private(set) var count: Int?
    private(set) var next: String?
    private(set) var previous: String?
    private(set) var results: [SHDiscoverItem] = []
    
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
