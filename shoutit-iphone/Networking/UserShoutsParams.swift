//
//  UserShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct UserShoutsParams: Params {
    
    let username: String
    let pageSize: Int
    let shoutType: ShoutType?
    
    var params: [String : AnyObject] {
        return [
            "page_size" : pageSize,
            "shout_type" :  (shoutType != nil) ? shoutType!.rawValue : "all"
        ]
    }
}
