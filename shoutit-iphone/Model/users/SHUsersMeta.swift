//
//  TableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 11/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHUsersMeta: Mappable {
    var next = String()
    var previous = String()
    var users = [SHUser]()
    var results = [SHUser]()
    var count = 0
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        next                   <- map["next"]
        previous               <- map["previous"]
        users                  <- map["users"]
        count                  <- map["count"]
        results                <- map["results"]
    }
}
