//
//  SHApiMiscService.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 07/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class SHApiMiscService: NSObject {
    
    private let GEOCODE_URL = SHApiManager.sharedInstance.BASE_URL + "/misc/geocode"
    
    func geocodeLocation(location: CLLocationCoordinate2D, cacheResponse: SHAddress -> Void, completionHandler: Response<SHAddress, NSError> -> Void) {
        let params = [
            "latlng": "\(location.latitude),\(location.longitude)"
        ]
        SHApiManager.sharedInstance.get(GEOCODE_URL, params: params, cacheKey: Constants.Cache.SHAddress, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

}
