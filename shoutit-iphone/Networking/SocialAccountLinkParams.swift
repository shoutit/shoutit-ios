//
//  SocialAccountLinkParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum SocialAccountLinkParams: Params {
    
    case Facebook(token: String?)
    case Google(code: String?)
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        switch self {
        case .Facebook(let token):
            p["account"] = "facebook"
            p["facebook_access_token"] = token
        case .Google(let code):
            p["account"] = "gplus"
            p["gplus_code"] = code
        }
        return p
    }
}
