//
//  SHMessagesMeta.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHMessagesMeta: Mappable {
    var next = String()
    var previous = String()
    var results = [SHMessage]()
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        next                   <- map["next"]
        previous               <- map["previous"]
        results                <- map["results"]
    }
    
}
