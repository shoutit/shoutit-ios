//
//  GoogleAccount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct GoogleAccount {
    public let gplusId: String
}

extension GoogleAccount: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        gplusId = try decoder.decode("gplus_id")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(gplusId, key: "gplus_id")
        })
    }
}
