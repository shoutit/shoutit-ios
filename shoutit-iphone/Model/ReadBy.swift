//
//  ReadBy.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct ReadBy: Hashable, Equatable {
    let profileId: String
    let readAt: Int
    
    public var hashValue: Int {
        get {
            return self.profileId.hashValue
        }
    }
}

extension ReadBy: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        profileId = try decoder.decode("profile_id")
        readAt = try decoder.decode("read_at")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(profileId, key: "profile_id")
            try encoder.encode(readAt, key: "read_at")
        })
    }
}

public func ==(lhs: ReadBy, rhs: ReadBy) -> Bool {
    return lhs.profileId == rhs.profileId
}
