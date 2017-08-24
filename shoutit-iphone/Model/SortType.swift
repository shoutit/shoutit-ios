//
//  SortType.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable


public struct SortType {
    public let type: String
    public let name: String
}

extension SortType: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        type = try decoder.decode("type")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(type, key: "type")
        })
    }
}
