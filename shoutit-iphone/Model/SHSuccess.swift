//
//  SHSuccess.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 07/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHSuccess: Mappable {

    private(set) var successMessage: String?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        successMessage <- map["success"]
    }
    
}
