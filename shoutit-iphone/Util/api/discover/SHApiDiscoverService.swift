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
    
    private let DISCOVER_BY_COUNTRY = SHApiManager.sharedInstance.BASE_URL + "/discover"
    private let locationCache = SHOauthToken.getFromCache()?.user?.location
    
    func getItemsForLocation(country: String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHUser, NSError> -> Void) {
        if let country = locationCache?.country {
            let params = [
                "country": country
            ]
            SHApiManager.sharedInstance.get(DISCOVER_BY_COUNTRY, params: params, cacheKey: Constants.Cache.OauthToken, completionHandler: completionHandler)
        }
        
        
    }
    
}
