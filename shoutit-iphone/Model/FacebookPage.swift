//
//  FacebookPage.swift
//  shoutit
//
//  Created by Piotr Bernad on 20/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct FacebookPage {
    public let perms: [String]
    public let facebookId: String
    public let name: String
}

extension FacebookPage: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        perms = try decoder.decode("perms")
        facebookId = try decoder.decode("facebook_id")
        name = try decoder.decode("name")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(perms, key: "perms")
            try encoder.encode(facebookId, key: "facebook_id")
            try encoder.encode(name, key: "name")
        })
    }
}
