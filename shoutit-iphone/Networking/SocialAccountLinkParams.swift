//
//  SocialAccountLinkParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public enum SocialAccountLinkParams: Params {
    
    case facebook(token: String?)
    case google(code: String?)
    case facebookPage(pageId: String?)
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        switch self {
        case .facebook(let token):
            p["account"] = "facebook" as AnyObject
            p["facebook_access_token"] = token as AnyObject
        case .google(let code):
            p["account"] = "gplus" as AnyObject
            p["gplus_code"] = code as AnyObject
        case .facebookPage(let pageId):
            p["facebook_page_id"] = pageId as AnyObject
        }
        return p
    }
}
