//
//  SHMedia.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHMedia: Mappable {

    var url = String()
    var thumbnailUrl = String()
    var provider = String()
    var idOnProvider = String()
    var duration: Int64 = 0
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        url                 <- map["url"]
        thumbnailUrl        <- map["thumbnail_url"]
        provider            <- map["provider"]
        idOnProvider        <- map["id_on_provider"]
        duration            <- map["duration"]
    }
    
}
