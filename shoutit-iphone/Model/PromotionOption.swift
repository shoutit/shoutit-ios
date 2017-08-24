//
//  PromotionOption.swift
//  shoutit
//
//  Created by Piotr Bernad on 16/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct PromotionOption {
    public let id: String
    public let name: String
    public let credits: Int
    public let days: Int?
    public let label: PromotionLabel
}

extension PromotionOption: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        name = try decoder.decode("name")
        credits = try decoder.decode("credits")
        days = try decoder.decode("days")
        label = try decoder.decode("label")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(name, key: "name")
            try encoder.encode(credits, key: "credits")
            try encoder.encode(days, key: "days")
            try encoder.encode(label, key: "label")
        })
    }
}
