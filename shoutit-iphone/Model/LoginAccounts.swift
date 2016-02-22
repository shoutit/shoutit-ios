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
    let gplus: Bool
    let facebook: Bool
}

extension LoginAccounts: Decodable {
    
    static func decode(j: JSON) -> Decoded<LoginAccounts> {
        return curry(LoginAccounts.init)
            <^> j <| "gplus"
            <*> j <| "facebook"
    }
}

extension LoginAccounts: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "gplus"    : self.gplus.encode(),
            "facebook"  : self.facebook.encode()
            ])
    }
}