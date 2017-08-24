//
//  MiniProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct MiniProfile {
    public let id: String
    public let username: String
    public let name: String?
    
    public init (id: String, username: String, name: String?) {
        self.id = id
        self.username = username
        self.name = name
    }
}

extension MiniProfile: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        username = try decoder.decode("username")
        name = try decoder.decode("name")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(username, key: "username")
            try encoder.encode(name, key: "name")
        })
    }
}
