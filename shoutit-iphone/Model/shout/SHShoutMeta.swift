//
//  SHShoutMeta.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHShoutMeta: Mappable {
    
    private(set) var next = String()
    private(set) var previous = String()
//    var results = [SHShout]()
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        next               <- map["next"]
        previous           <- map["previous"]
//        results            <- map["results"]
    }
}
