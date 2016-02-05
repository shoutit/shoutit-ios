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
    
    private(set) var address: String = ""
    private(set) var city: String = ""
    private(set) var country: String = ""
    private(set) var latitude: Double?
    private(set) var longitude: Double?
    private(set) var postalCode: String = ""
    private(set) var state: String = ""
}

extension Address: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try address         <~> map["address"]
        try city            <~> map["city"]
        try country         <~> map["country"]
        try latitude        <~> map["latitude"]
        try longitude       <~> map["longitude"]
        try postalCode      <~> map["postal_code"]
        try state           <~> map["state"]
    }
}
