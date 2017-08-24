//
//  Mobile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 30.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable


public struct Mobile {
    public let phone: String
    public init(phone: String) {
        self.phone = phone
    }
}

extension Mobile: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        phone = try decoder.decode("mobile")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(phone, key: "mobile")
        })
    }
}
