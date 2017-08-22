//
//  LoginAccounts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct LoginAccounts {
    public let facebook: FacebookAccount?
    public let gplus: GoogleAccount?
    public let facebookPage: FacebookPage?
}

extension LoginAccounts: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<LoginAccounts> {
        return curry(LoginAccounts.init)
            <^> j <|? "facebook"
            <*> j <|? "gplus"
            <*> j <|? "facebook_page"
    }
}

extension LoginAccounts: Encodable {
    
    public func encode() -> JSON {
        return JSON.object([
            "facebook"  : self.facebook.encode(),
            "gplus"    : self.gplus.encode(),
            "facebook_page" : self.facebookPage.encode()
            ])
    }
}
