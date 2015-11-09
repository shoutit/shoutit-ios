//
//  SHApiDiscoverService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiDiscoverService: NSObject {
    
    private let DISCOVER_FEED = SHApiManager.sharedInstance.BASE_URL + "/discover"
    private let DISCOVER_FEED_ITEMS = SHApiManager.sharedInstance.BASE_URL + "/discover/%@"
    private let location = SHAddress.getUserOrDeviceLocation()
    
    func getDiscoverLocation(cacheResponse: SHDiscoverLocation -> Void, completionHandler: Response<SHDiscoverLocation, NSError> -> Void) {
        if let country = location?.country {
            let params = [
                "country": country
            ]
            SHApiManager.sharedInstance.get(DISCOVER_FEED, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
        }
    }
    
    func getItemsFeedForLocation(id: String, cacheResponse: SHDiscoverItem -> Void, completionHandler: Response<SHDiscoverItem, NSError> -> Void) {
        SHApiManager.sharedInstance.get(String(format: DISCOVER_FEED_ITEMS, id), params: nil, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
}
