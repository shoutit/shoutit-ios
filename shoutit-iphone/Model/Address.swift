//
//  Address.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct Address {
    
    let address: String
    let city: String
    let country: String
    let latitude: Double?
    let longitude: Double?
    let postalCode: String
    let state: String
}

extension Address: MappableObject {
    
    init(map: Map) throws {
        address = try map.extract("address")
        city = try map.extract("city")
        country = try map.extract("country")
        latitude = try map.extract("latitude")
        longitude = try map.extract("longitude")
        postalCode = try map.extract("postal_code")
        state = try map.extract("state")
    }
    
    func sequence(map: Map) throws {
        try address         ~> map["address"]
        try city            ~> map["city"]
        try country         ~> map["country"]
        try latitude        ~> map["latitude"]
        try longitude       ~> map["longitude"]
        try postalCode      ~> map["postal_code"]
        try state           ~> map["state"]
    }
}
