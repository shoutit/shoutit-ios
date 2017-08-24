//
//  Address.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Address {
    
    public let address: String?
    public let city: String
    public let country: String
    public let latitude: Double?
    public let longitude: Double?
    public let postalCode: String
    public let state: String
    
    public init(address: String?, city: String, country: String, latitude: Double?, longitude: Double?, postalCode: String, state: String) {
        self.address = address
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.postalCode = postalCode
        self.state = state
    }
}

extension Address: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        address = try decoder.decode("address")
        city = try decoder.decode("city")
        country = try decoder.decode("country")
        latitude = try decoder.decode("latitude")
        longitude = try decoder.decode("longitude")
        postalCode = try decoder.decode("postal_code")
        state = try decoder.decode("state")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(address, key: "address")
            try encoder.encode(city, key: "city")
            try encoder.encode(country, key: "country")
            try encoder.encode(latitude, key: "latitude")
            try encoder.encode(longitude, key: "longitude")
            try encoder.encode(postalCode, key: "postal_code")
            try encoder.encode(state, key: "state")
        })
    }
}
