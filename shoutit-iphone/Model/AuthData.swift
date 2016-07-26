//
//  AuthData.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct ExpirationDate : Decodable {
    public let expireTimeStamp : Int
    
    public static func decode(json: JSON) -> Decoded<ExpirationDate> {
        switch json {
        case .Number(let timeStamp):
            let date : Int = Int(NSDate().timeIntervalSince1970)
            let expiresAt = date + 10 // Int(timeStamp)
            return .Success(ExpirationDate(expireTimeStamp: expiresAt))
        default:
            
            return Decoded.Failure(DecodeError.Custom("Could not parse token expiration date"))
        }
    }
    
    public func isExpired() -> Bool {
        if (expireTimeStamp - 10) > Int(NSDate().timeIntervalSince1970) {
            return true
        }
        
        return false
    }
    
}

public struct AuthData {
    
    // token
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresInEpoch: Int
    
    // other
    public let isNewSignUp: Bool
    public let scope: String
    public let expireAt: ExpirationDate
}

extension AuthData: Decodable {
    
    public static func decode(j: JSON) -> Decoded<AuthData> {
        let a = curry(AuthData.init)
            <^> j <| "access_token"
            <*> j <| "refresh_token"
            <*> j <| "token_type"
        let b = a
            <*> j <| "expires_in"
            <*> j <| "new_signup"
        let c = b
            <*> j <| "scope"
            <*> j <| "expires_in"
        return c
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
    
    public func isExpired() -> Bool {
        return expireAt.isExpired()
    }
    
    public func expiresAt() -> Int {
        return expireAt.expireTimeStamp
    }
}
