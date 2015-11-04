//
//  SHAddress.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 05/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation
import MapKit

class SHAddress: NSObject {

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
    
    class func addressComponent(component: String, inAddressArray array: [AnyObject], ofType type: String) -> String {
        
        
    }
    
}
