//
//  SHUser.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import ObjectMapper

class SHUser: Mappable {
    
    private(set) var apiUrl: String?
    private(set) var bio: String = ""
    private(set) var id: String?
    
    required init?(_ map: Map) {
        
    }

    // Mappable
    func mapping(map: Map) {
        apiUrl              <- map["api_url"]
        bio                 <- map["bio"]
        id                  <- map["id"]
    }
}
