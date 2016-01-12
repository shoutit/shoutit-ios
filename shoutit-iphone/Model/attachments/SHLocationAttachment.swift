//
//  SHLocationAttachment.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 07/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHLocationAttachment: Mappable {
    var location: SHAddress?
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        location                   <- map["location"]
    }
}
