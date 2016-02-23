//
//  AuthData.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct AuthData {
    
    // token type
    //private(set) var guest: Bool = false
    
    // token
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresInEpoch: Int
    
    // other
    let isNewSignUp: Bool
    let scope: String
}

extension AuthData: Decodable {
    
    static func decode(j: JSON) -> Decoded<AuthData> {
        let f = curry(AuthData.init)
            <^> j <| "access_token"
            <*> j <| "refresh_token"
            <*> j <| "token_type"
        let g = f
            <*> j <| "expires_in"
            <*> j <| "new_signup"
            <*> j <| "scope"
        return g
    }
}

extension AuthData: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "access_token"    : self.accessToken.encode(),
            "refresh_token"  : self.refreshToken.encode(),
            "token_type" : self.tokenType.encode(),
            "expires_in"    : self.expiresInEpoch.encode(),
            "new_signup" : self.isNewSignUp.encode(),
            "scope" : self.scope.encode(),
            ])
    }
}
