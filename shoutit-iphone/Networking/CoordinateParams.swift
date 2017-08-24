//
//  CoordinateParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation

public struct CoordinateParams: Params {
    public let coordinates: CLLocationCoordinate2D
    
    public var params: [String : AnyObject] {
        return [
            "location" : [
                "latitude": coordinates.latitude,
                "longitude": coordinates.longitude
            ] as AnyObject
        ]
    }
    
    public init(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}
