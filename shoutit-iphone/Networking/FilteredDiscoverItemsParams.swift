//
//  FilteredDiscoverItemsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct FilteredDiscoverItemsParams: Params, PagedParams, LocalizedParams {
    
    let page: Int?
    let pageSize: Int?
    let country: String?
    let state: String?
    let city: String?
    
    init(page: Int? = 1,
         pageSize: Int? = 5,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
         useLocaleBasedCountryCodeWhenNil: Bool = false,
         includeCurrentUserLocation: Bool = false) {
        
        self.page = page
        self.pageSize = pageSize
        
        let location = includeCurrentUserLocation ? Account.sharedInstance.user?.location : nil
        if country == nil && location?.country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country ?? location?.country ?? ""
        }
        self.state = state ?? location?.state
        self.city = city ?? location?.city
    }
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        for (key, value) in localizedParams {
            p[key] = value
        }
        
        return p
    }
}
