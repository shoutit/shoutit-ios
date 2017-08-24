//
//  TwilioAuth.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct TwilioAuth {
    public let token: String
    public let identity: String
}

extension TwilioAuth: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        token = try decoder.decode("token")
        identity = try decoder.decode("identity")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(token, key: "token")
            try encoder.encode(identity, key: "identity")
        })
    }
}

public struct TwilioIdentity {
    public let identity: String

    public init(identity: String) {
        self.identity = identity
    }
}

extension TwilioIdentity: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        identity = try decoder.decode("identity")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(identity, key: "identity")
        })
    }
}
