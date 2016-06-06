//
//  GeocodeParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct GeocodeParams: Params {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public var params: [String : AnyObject] {
        let geocodeValue : String = "\(latitude),\(longitude)"
        return ["latlng" : geocodeValue] as Dictionary<String, AnyObject>
    }
}
