//
//  Address.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra
import FTGooglePlacesAPI

struct Address {
    
    let address: String
    let city: String
    let country: String
    let latitude: Double?
    let longitude: Double?
    let postalCode: String
    let state: String
}

extension Address: Decodable {
    
    static func decode(j: JSON) -> Decoded<Address> {
        let f = curry(Address.init)
            <^> j <| "address"
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
    
    func encode() -> JSON {
        return JSON.Object([
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

extension FTGooglePlacesAPISearchResultItem {
    func toAddressObject() -> Address {
        return Address(address: self.addressString, city: "", country: "", latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude, postalCode: "", state: "")
    }
}