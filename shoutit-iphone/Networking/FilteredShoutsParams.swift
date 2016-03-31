//
//  FilteredShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct FilteredShoutsParams: Params, PagedParams, LocalizedParams {
    
    let searchPhrase: String?
    let discoverId: String?
    let username: String?
    let tag: String?
    let page: Int?
    let pageSize: Int?
    let country: String?
    let state: String?
    let city: String?
    let shoutType: ShoutType?
    
    init(searchPhrase: String? = nil,
         discoverId: String? = nil,
         username: String? = nil,
         tag: String? = nil,
         page: Int? = 1,
         pageSize: Int? = 4,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
         shoutType: ShoutType? = nil,
         useLocaleBasedCountryCodeWhenNil: Bool = false,
         includeCurrentUserLocation: Bool = false) {
        
        self.searchPhrase = searchPhrase
        self.discoverId = discoverId
        self.username = username
        self.tag = tag
        self.page = page
        self.pageSize = pageSize
        self.shoutType = shoutType
        
        let location = includeCurrentUserLocation ? Account.sharedInstance.user?.location : nil
        if country == nil && location?.country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country ?? location?.country
        }
        self.state = state ?? location?.state
        self.city = city ?? location?.city
    }
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        
        p["search"] = searchPhrase
        p["discover"] = discoverId
        p["profile"] = username
        p["tags"] = tag
        p["shout_type"] = shoutType?.rawValue ?? "all"
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        for (key, value) in localizedParams {
            p[key] = value
        }
        
        return p
    }
}
