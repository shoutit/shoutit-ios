//
//  MessageParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct MessageParams: Params, JSONEncodable {
    let message: Message
    
    public init(message: Message) {
        self.message = message
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(message, key: "message")
        })
    }
}
