//
//  TypingInfo.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 27/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import JSONCodable

public struct TypingInfo {
    public let id: String
    public let username: String
    
    public init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}

extension TypingInfo: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        username = try decoder.decode("username")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(username, key: "username")
        })
    }
}
