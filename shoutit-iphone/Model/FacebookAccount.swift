//
//  FacebookAccount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct FacebookAccount {
    let scopes: [String]
    let expiresAtEpoch: Int
    let facebookId: String
}

extension FacebookAccount: Decodable {
    
    static func decode(j: JSON) -> Decoded<FacebookAccount> {
        return curry(FacebookAccount.init)
            <^> j <|| "scopes"
            <*> j <| "expires_at"
            <*> j <| "facebook_id"
    }
}

extension FacebookAccount: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "scopes"    : scopes.encode(),
            "expires_at"  : expiresAtEpoch.encode(),
            "facebook_id" : facebookId.encode()
            ]
        )
    }
}
