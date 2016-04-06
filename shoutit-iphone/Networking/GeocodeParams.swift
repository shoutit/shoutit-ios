//
//  GeocodeParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct GeocodeParams: Params {
    let latitude: Double
    let longitude: Double
    
    var params: [String : AnyObject] {
        return ["latlng" : "\(latitude),\(longitude)"]
    }
}
