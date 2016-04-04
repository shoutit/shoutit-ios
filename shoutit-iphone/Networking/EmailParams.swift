//
//  EmailParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 30.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct EmailParams: Params {
    let email: String?
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["email"] = email
        return p
    }
}
