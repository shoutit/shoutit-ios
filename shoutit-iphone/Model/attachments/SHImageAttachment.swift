//
//  SHImageAttachment.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHImageAttachment: Mappable {
    
    var localImages = [SHMedia]()
    var images = [String]()
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        localImages                   <- map["localImages"]
        images                        <- map["images"]
    }
}
