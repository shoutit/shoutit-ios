//
//  Currency.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Currency {
    
    public let code: String
    public let country: String
    public let name: String
    
    public init(code: String, country: String, name: String) {
        self.code = code
        self.country = country
        self.name = name
    }
}

extension Currency: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        code = try decoder.decode("code")
        country = try decoder.decode("country")
        name = try decoder.decode("name")
    }
    
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(code, key: "code")
            try encoder.encode(country, key: "country")
            try encoder.encode(name, key: "name")
        })
    }
}
