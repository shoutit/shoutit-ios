//
//  CreatePublicChatParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct CreatePublicChatParams: Params {
    let subject: String
    let iconPath: String?
    
    var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        params["subject"] = subject
        params["icon"] = iconPath
        return params
    }
}
