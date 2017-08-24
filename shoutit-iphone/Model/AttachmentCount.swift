//
//  AttachmentCount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 19.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct AttachmentCount {
    public let shout: Int
    public let media: Int
    public let profile: Int
    public let location: Int
    
    public static var zeroCount: AttachmentCount {
        return AttachmentCount(shout: 0,
                               media: 0,
                               profile: 0,
                               location: 0)
    }
}

extension AttachmentCount: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        shout = try decoder.decode("shout")
        media = try decoder.decode("media")
        profile = try decoder.decode("profile")
        location = try decoder.decode("location")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(shout, key: "shout")
            try encoder.encode(media, key: "media")
            try encoder.encode(profile, key: "profile")
            try encoder.encode(location, key: "location")
        })
    }
}
