//
//  SHAddress.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 05/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MapKit
import ObjectMapper

class SHAddress: Mappable {

    private(set) var address = String()
    private(set) var city = String()
    private(set) var country = String()
    private(set) var latitude: Float?
    private(set) var longitude: Float?
    private(set) var postalCode: String?
    private(set) var state =  String()
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        address         <- map["address"]
        city            <- map["city"]
        country         <- map["country"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
        postalCode      <- map["postal_code"]
        state           <- map["state"]
    }
    
//    static func getUserOrDeviceLocation() -> SHAddress? {
//        var shAddress: SHAddress? = nil
//        if let oauthToken = SHOauthToken.getFromCache() {
//            shAddress = oauthToken.user?.location
//        }
//        return shAddress
//    }
    
}
