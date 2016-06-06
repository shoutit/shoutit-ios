//
//  FilteredDiscoverItemsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct FilteredDiscoverItemsParams: Params, PagedParams, LocalizedParams {
    
    public let page: Int?
    public let pageSize: Int?
    public let country: String?
    public let state: String?
    public let city: String?
    public var location: Address?
    // Account.sharedInstance.user?.location
    
    public init(page: Int? = 1,
         pageSize: Int? = 5,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
         location: Address?,
         useLocaleBasedCountryCodeWhenNil: Bool = false) {
        
        self.page = page
        self.pageSize = pageSize
        
        if country == nil && location?.country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country ?? location?.country ?? ""
        }
        self.state = state ?? location?.state
        self.city = city ?? location?.city
    }
    
    public var params: [String : AnyObject] {
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
