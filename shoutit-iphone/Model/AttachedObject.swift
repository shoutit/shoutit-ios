//
//  AttachedObject.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct AttachedObject {
    
    let profile : Profile?
    let shout : Shout?
    let message : Message?
}

extension AttachedObject: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
         profile = try decoder.decode("profile")
         shout = try decoder.decode("shout")
         message = try decoder.decode("message")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(profile, key: "profile")
            try encoder.encode(shout, key: "shout")
            try encoder.encode(message, key: "message")
        })
    }
}
