//
//  APNParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable


public struct APNParams: Params, JSONEncodable {
    public let tokens: PushTokens
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(tokens, key: "push_tokens")
        })
    }
    
    public init(tokens: PushTokens) {
        self.tokens = tokens
    }
}
