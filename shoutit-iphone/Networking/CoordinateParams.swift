//
//  CoordinateParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct CoordinateParams: Params {
    let coordinates: CLLocationCoordinate2D
    
    var params: [String : AnyObject] {
        return [
            "location" : [
                "latitude": coordinates.latitude,
                "longitude": coordinates.longitude
            ]
        ]
    }
}