//
//  PushTokens.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct PushTokens {
    public let apns: String?
    public let gcm: String?
    
    public init(apns: String?, gcm: String?) {
            self.apns = apns
            self.gcm = gcm
    }
}


extension PushTokens: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        apns = try decoder.decode("apns")
        gcm = try decoder.decode("gcm")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(apns, key: "apns")
            try encoder.encode(gcm, key: "gcm")
        })
    }
}
