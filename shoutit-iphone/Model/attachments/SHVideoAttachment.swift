//
//  SHVideoAttachment.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHVideoAttachment: Mappable {

    var videos = [SHMedia]()
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        videos                   <- map["videos"]
    }
}
