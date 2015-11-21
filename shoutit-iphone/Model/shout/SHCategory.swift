//
//  SHCategory.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHCategory: Mappable {
    
    var name = String()
    var slug = String()
    var mainTag:SHTag?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        name            <- map["name"]
        slug            <- map["slug"]
        mainTag         <- map["main_tag"]
    }
    
}
