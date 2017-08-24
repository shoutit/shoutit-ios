//
//  Promotion.swift
//  shoutit
//
//  Created by Piotr Bernad on 15/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Promotion {
    public let id: String
    public let days: Int?
    public let isExpired:  Bool
    public let label: PromotionLabel?
    public let expiresAt: Int?
}

extension Promotion: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        days = try decoder.decode("days")
        isExpired = try decoder.decode("is_expired")
        label = try decoder.decode("label")
        expiresAt = try decoder.decode("expires_at")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(days, key: "days")
            try encoder.encode(isExpired, key: "is_expired")
            try encoder.encode(label, key: "label")
            try encoder.encode(expiresAt, key: "expires_at")
        })
    }
}

public struct PromotionLabel {
    public let name : String
    public let description: String
    public let color: String
    public let backgroundColor: String
}

extension PromotionLabel: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        name = try decoder.decode("name")
        description = try decoder.decode("description")
        color = try decoder.decode("color")
        backgroundColor = try decoder.decode("bg_color")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(name, key: "name")
            try encoder.encode(description, key: "description")
            try encoder.encode(color, key: "color")
            try encoder.encode(backgroundColor, key: "bg_color")
        })
    }
}
