//
//  ConversationUpdateParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 17/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

struct ConversationUpdateParams: Params {
    let subject : String?
    let icon: String? = nil
    
    var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        
        params["subject"] = subject
        
        if icon != nil {
            params["icon"] = icon
        }
        
        return params
    }
}
