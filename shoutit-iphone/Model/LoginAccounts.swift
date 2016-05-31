//
//  LoginAccounts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct LoginAccounts {
    let facebook: FacebookAccount?
    let gplus: GoogleAccount?
}

extension LoginAccounts: Decodable {
    
    static func decode(j: JSON) -> Decoded<LoginAccounts> {
        return curry(LoginAccounts.init)
            <^> j <|? "facebook"
            <*> j <|? "gplus"
    }
}

extension LoginAccounts: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "facebook"  : self.facebook.encode(),
            "gplus"    : self.gplus.encode()
            ])
    }
}