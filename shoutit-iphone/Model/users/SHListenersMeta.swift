//
//  SHListenersMeta.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 22/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHListenersMeta: Mappable {

    var pages = 0
    var users = 0
    var tags = 0
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        pages                   <- map["pages"]
        users                   <- map["users"]
        tags                    <- map["tags"]
    }

}
