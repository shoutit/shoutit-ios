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

class SHAddress: NSObject, NSCoding, Mappable {

    var fullAddress: String?
    var streetNumber: String?
    var route: String?
    var city: String?
    var stateCode: String?
    var countryCode: String?
    var postalCode: String?
    var countryName: String?
    var latitude: String?
    var longitude: String?
    var googleResponse: String?
    
    init(c: CLLocationCoordinate2D) {
        self.latitude = "\(c.latitude)"
        self.longitude = "\(c.longitude)"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        //Encode properties, other class variables, etc
        aCoder.encodeObject(self.fullAddress, forKey: "fullAddress")
        aCoder.encodeObject(self.streetNumber, forKey: "streetNumber")
        aCoder.encodeObject(self.route, forKey: "route")
        aCoder.encodeObject(self.city, forKey: "city")
        aCoder.encodeObject(self.stateCode, forKey: "stateCode")
        aCoder.encodeObject(self.postalCode, forKey: "postalCode")
        aCoder.encodeObject(self.countryName, forKey: "countryName")
        aCoder.encodeObject(self.countryCode, forKey: "countryCode")
        aCoder.encodeObject(self.latitude, forKey: "latitude")
        aCoder.encodeObject(self.longitude, forKey: "longitude")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //decode properties, other class vars
        self.fullAddress  = aDecoder.decodeObjectForKey("fullAddress")?.stringValue
        self.streetNumber = aDecoder.decodeObjectForKey("streetNumber")?.stringValue
        self.route        = aDecoder.decodeObjectForKey("route")?.stringValue
        self.city         = aDecoder.decodeObjectForKey("city")?.stringValue
        self.stateCode    = aDecoder.decodeObjectForKey("stateCode")?.stringValue
        self.postalCode   = aDecoder.decodeObjectForKey("postalCode")?.stringValue
        self.countryName  = aDecoder.decodeObjectForKey("countryName")?.stringValue
        self.countryCode  = aDecoder.decodeObjectForKey("countryCode")?.stringValue
        self.latitude     = aDecoder.decodeObjectForKey("latitude")?.stringValue
        self.longitude    = aDecoder.decodeObjectForKey("longitude")?.stringValue
        
    }
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        fullAddress     <- map["fullAddress"]
        streetNumber    <- map["streetNumber"]
        route           <- map["route"]
        city            <- map["city"]
        stateCode       <- map["stateCode"]
        countryCode     <- map["countryCode"]
        postalCode      <- map["postalCode"]
        countryName     <- (map["countryName"])
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
        googleResponse  <- (map["googleResponse"])
        
    }
    
    
   
    
}
