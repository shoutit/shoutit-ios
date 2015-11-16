//
//  SHCurrency.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHCurrency: Mappable {

    private(set) var code = String()
    private(set) var country = String()
    private(set) var name = String()
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        code            <- map["code"]
        country         <- map["country"]
        name            <- map["name"]
    }
    
}
