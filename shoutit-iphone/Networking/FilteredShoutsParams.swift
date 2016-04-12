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
    let category: String?
    let minimumPrice: Int?
    let maximumPrice: Int?
    let withinDistance: Int?
    let entireCountry: Bool
    let sort: SortType?
    let filters: [(Filter, [FilterValue])]?
    
    init(searchPhrase: String? = nil,
         discoverId: String? = nil,
         username: String? = nil,
         tag: String? = nil,
         page: Int? = nil,
         pageSize: Int? = nil,
         country: String? = nil,
         state: String? = nil,
         city: String? = nil,
         shoutType: ShoutType? = nil,
         category: String? = nil,
         minimumPrice: Int? = nil,
         maximumPrice: Int? = nil,
         withinDistance: Int? = nil,
         entireCountry: Bool = false,
         sort: SortType? = nil,
         filters: [(Filter, [FilterValue])]? = nil,
         useLocaleBasedCountryCodeWhenNil: Bool = false,
         includeCurrentUserLocation: Bool = false) {
        
        self.searchPhrase = searchPhrase
        self.discoverId = discoverId
        self.username = username
        self.tag = tag
        self.page = page
        self.pageSize = pageSize
        self.shoutType = shoutType
        self.category = category
        self.minimumPrice = minimumPrice
        self.maximumPrice = maximumPrice
        self.withinDistance = withinDistance
        self.entireCountry = entireCountry
        self.sort = sort
        self.filters = filters
        
        // location
        let location = includeCurrentUserLocation ? Account.sharedInstance.user?.location : nil
        if country == nil && location?.country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country ?? location?.country
        }
        self.state = state ?? location?.state
        self.city = city ?? location?.city
    }
    
    func paramsByReplacingEmptyFieldsWithFieldsFrom(other: FilteredShoutsParams) -> FilteredShoutsParams {
        return FilteredShoutsParams(searchPhrase: searchPhrase ?? other.searchPhrase,
                                    discoverId: discoverId ?? other.discoverId,
                                    username: username ?? other.username,
                                    tag: tag ?? other.tag,
                                    page: page ?? other.page,
                                    pageSize: pageSize ?? other.pageSize,
                                    country: country ?? other.country,
                                    state: state ?? other.state,
                                    city: city ?? other.city,
                                    shoutType: shoutType ?? other.shoutType,
                                    category: category ?? other.category,
                                    minimumPrice: minimumPrice ?? other.minimumPrice,
                                    maximumPrice: maximumPrice ?? other.maximumPrice,
                                    withinDistance: withinDistance ?? other.withinDistance,
                                    sort: sort ?? other.sort,
                                    filters: filters ?? other.filters)
    }
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        
        p["search"] = searchPhrase
        p["discover"] = discoverId
        p["profile"] = username
        p["tags"] = tag
        p["shout_type"] = shoutType?.rawValue ?? "all"
        p["category"] = category
        p["min_price"] = minimumPrice
        p["max_price"] = maximumPrice
        p["sort"] = sort?.type
        p["within"] = withinDistance
        filters?.forEach({ (filter, values) in
            let valuesString = values.map{$0.slug}.joinWithSeparator(",")
            if valuesString.utf16.count > 0 {
                p[filter.slug] = valuesString
            }
        })
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        if entireCountry {
            p["country"] = self.country
        } else {
            for (key, value) in localizedParams {
                p[key] = value
            }
        }
        
        return p
    }
}
