//
//  FacebookAccount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct FacebookAccount {
    public let scopes: [String]
    public let expiresAtEpoch: Int
    public let facebookId: String
}

extension FacebookAccount: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<FacebookAccount> {
        return curry(FacebookAccount.init)
            <^> j <|| "scopes"
            <*> j <| "expires_at"
            <*> j <| "facebook_id"
    }
}

extension FacebookAccount: Encodable {
    
    public func encode() -> JSON {
        return JSON.object([
            "scopes"    : scopes.encode(),
            "expires_at"  : expiresAtEpoch.encode(),
            "facebook_id" : facebookId.encode()
            ]
        )
    }
}
