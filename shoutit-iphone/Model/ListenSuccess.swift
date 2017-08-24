//
//  ListenSuccess.swift
//  shoutit
//
//  Created by Piotr Bernad on 01/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct ListenSuccess {
    public let message: String
    public let newListnersCount: Int
    
    public init(message: String, newListnersCount: Int = 0) {
        self.message = message
        self.newListnersCount = newListnersCount
    }
}

extension ListenSuccess: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        message = try decoder.decode("success")
        newListnersCount = try decoder.decode("new_listeners_count")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(message, key: "success")
            try encoder.encode(newListnersCount, key: "new_listeners_count")
        })
    }
}
