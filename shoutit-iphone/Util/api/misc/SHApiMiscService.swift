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
    private let CATEGORIES_URL = SHApiManager.sharedInstance.BASE_URL + "/misc/categories"
    private let CURRENCIES_URL = SHApiManager.sharedInstance.BASE_URL + "/misc/currencies"

    func geocodeLocation(location: CLLocationCoordinate2D, cacheKey: String? = nil, cacheResponse: (SHAddress -> Void)? = nil, completionHandler: Response<SHAddress, NSError> -> Void) {
        let params = [
            "latlng": "\(location.latitude),\(location.longitude)"
        ]
        SHApiManager.sharedInstance.get(GEOCODE_URL, params: params, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

    func getCategories(cacheResponse: (Array<SHCategory> -> Void)? = nil, completionHandler: Response<Array<SHCategory>, NSError> -> Void) {
        SHApiManager.sharedInstance.getArray(CATEGORIES_URL, params: nil, cacheKey: Constants.Cache.Categories, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

    func getCurrencies(cacheResponse: (Array<SHCurrency> -> Void)? = nil, completionHandler: Response<Array<SHCurrency>, NSError> -> Void) {
        SHApiManager.sharedInstance.getArray(CURRENCIES_URL, params: nil, cacheKey: Constants.Cache.Currencies, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }

}
