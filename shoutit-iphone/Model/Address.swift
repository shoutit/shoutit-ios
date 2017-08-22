//
//  Address.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

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

extension Address: Decodable {
    
    public static func decode(_ j: JSON) -> Decoded<Address> {
        let f = curry(Address.init)
            <^> j <|? "address"
            <*> j <| "city"
            <*> j <| "country"
        return f
            <*> j <|? "latitude"
            <*> j <|? "longitude"
            <*> j <| "postal_code"
            <*> j <| "state"
    }
}

extension Address: Encodable {
    
    public func encode() -> JSON {
        return JSON.object([
            "address"    : self.address.encode(),
            "city"  : self.city.encode(),
            "country" : self.country.encode(),
            "latitude"    : self.latitude.encode(),
            "longitude"  : self.longitude.encode(),
            "postal_code" : self.postalCode.encode(),
            "state" : self.state.encode(),
        ])
    }
}
