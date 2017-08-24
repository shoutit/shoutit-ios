//
//  InvitationCode.swift
//  shoutit
//
//  Created by Piotr Bernad on 22.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct InvitationCode {
    public let id: String
    public let createdAt: Int
    public let code: String
}

extension InvitationCode: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        createdAt = try decoder.decode("created_at")
        code = try decoder.decode("code")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(createdAt, key: "created_at")
            try encoder.encode(code, key: "code")
        })
    }
}
