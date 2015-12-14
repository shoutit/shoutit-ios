//
//  SHLoginAccounts.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 10/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHLoginAccounts: Mappable {
    var gplus: Bool?
    var facebook: Bool?
    
    required init?(_ map: Map) {
        
    }
    
    init() {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        gplus                <- map["gplus"]
        facebook             <- map["facebook"]
    }
}
