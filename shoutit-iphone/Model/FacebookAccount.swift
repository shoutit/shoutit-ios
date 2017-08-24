//
//  FacebookAccount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct FacebookAccount {
    public let scopes: [String]
    public let expiresAtEpoch: Int
    public let facebookId: String
}

extension FacebookAccount: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        scopes = try decoder.decode("scopes")
        expiresAtEpoch = try decoder.decode("expires_at")
        facebookId = try decoder.decode("facebook_id")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(scopes, key: "scopes")
            try encoder.encode(expiresAtEpoch, key: "expires_at")
            try encoder.encode(facebookId, key: "facebook_id")
        })
    }
}
