//
//  AuthData.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public let IntToExpirationDate = JSONTransformer<Int, ExpirationDate>(
    decoding: {ExpirationDate($0)},
    encoding: {$0.expireTimeStamp})


public struct ExpirationDate {
    public let expireTimeStamp : Int
    
    public init(_ expireTimeStamp: Int) {
        self.expireTimeStamp = expireTimeStamp + Int(Date().timeIntervalSince1970)
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

extension AuthData: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        accessToken = try decoder.decode("access_token")
        refreshToken = try decoder.decode("refresh_token")
        tokenType = try decoder.decode("token_type")
        expiresInEpoch = try decoder.decode("expires_in")
        isNewSignUp = try decoder.decode("new_signup")
        scope = try decoder.decode("scope")
        expireAt = try decoder.decode("expires_in", transformer: IntToExpirationDate)
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(accessToken, key: "access_token")
            try encoder.encode(refreshToken, key: "refresh_token")
            try encoder.encode(tokenType, key: "token_type")
            try encoder.encode(expiresInEpoch, key: "expires_in")
            try encoder.encode(isNewSignUp, key: "new_signup")
            try encoder.encode(scope, key: "scope")            
        })
    }
}

extension AuthData {
    
    public var apiToken: String {
        return "\(tokenType) \(accessToken)"
    }
    
    public func expiresAt() -> Int {
        return expireAt.expireTimeStamp
    }
}
