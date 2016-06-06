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

public struct AuthData {
    
    // token
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresInEpoch: Int
    
    // other
    public let isNewSignUp: Bool
    public let scope: String
}

extension AuthData: Decodable {
    
    public static func decode(j: JSON) -> Decoded<AuthData> {
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
    
    public func encode() -> JSON {
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

extension AuthData {
    
    public var apiToken: String {
        return "\(tokenType) \(accessToken)"
    }
}
