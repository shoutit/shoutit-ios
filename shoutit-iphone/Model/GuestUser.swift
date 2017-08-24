//
//  GuestUser.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct GuestUser: User {
    
    public let id: String
    public let type: UserType
    public let isGuest: Bool
    public let apiPath: String
    public let username: String
    public let dateJoinedEpoch: Int
    public let location: Address
    public let pushTokens: PushTokens?
    public var name: String {
        return username
    }
}

extension GuestUser: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id = try decoder.decode("id")
        type = try decoder.decode("type")
        isGuest = try decoder.decode("is_guest")
        apiPath = try decoder.decode("api_url")
        username = try decoder.decode("username")
        dateJoinedEpoch = try decoder.decode("date_joined")
        location = try decoder.decode("location")
        pushTokens = try decoder.decode("push_tokens")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            
            try encoder.encode(id, key: "id")
            try encoder.encode(type, key: "type")
            try encoder.encode(isGuest, key: "is_guest")
            try encoder.encode(apiPath, key: "api_url")
            try encoder.encode(username, key: "username")
            try encoder.encode(dateJoinedEpoch, key: "date_joined")
            try encoder.encode(location, key: "location")
            try encoder.encode(pushTokens, key: "push_tokens")
        })
    }
}
