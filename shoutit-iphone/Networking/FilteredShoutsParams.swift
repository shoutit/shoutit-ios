//
//  FilteredShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public struct FilteredShoutsParams: Params, PagedParams, LocalizedParams {
    
    public let searchPhrase: String?
    public let discoverId: String?
    public let username: String?
    public let tag: String?
    public let page: Int?
    public let pageSize: Int?
    public let country: String?
    public let state: String?
    public let city: String?
    public let shoutType: ShoutType?
    public let category: String?
    public let minimumPrice: Int?
    public let maximumPrice: Int?
    public let withinDistance: Int?
    public let entireCountry: Bool
    public let sort: SortType?
    public let excludeId: String?
    public let skipLocation: Bool?
    public let filters: [(Filter, [FilterValue])]?
    public let currentUserLocation: Address?
    public let passCountryOnly: Bool?
    public let attachCityAndState: Bool?
    
    public init(searchPhrase: String? = nil,
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
         currentUserLocation: Address? = nil,
         skipLocation: Bool?,
         passCountryOnly: Bool? = false,
         excludeId: String? = nil,
         attachCityAndState: Bool = false) {
        
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
        self.currentUserLocation = currentUserLocation
        self.excludeId = excludeId
        self.skipLocation = skipLocation
        self.passCountryOnly = passCountryOnly
        
        self.attachCityAndState = attachCityAndState
        
        if let skipLocation = skipLocation {
            if skipLocation == true {
                self.country = nil
                self.city = nil
                self.state = nil
                return
            }
        }
        // location
        let location = currentUserLocation
        if country == nil && location?.country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
        } else {
            self.country = country ?? location?.country
        }
        self.state = state ?? location?.state
        self.city = city ?? location?.city
        
        
    }
    
    public func paramsByReplacingEmptyFieldsWithFieldsFrom(_ other: FilteredShoutsParams) -> FilteredShoutsParams {
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
                                    entireCountry: entireCountry,
                                    sort: sort ?? other.sort,
                                    filters: filters ?? other.filters,
                                    currentUserLocation: currentUserLocation,
                                    skipLocation: other.skipLocation,
                                    passCountryOnly: other.passCountryOnly)
    }
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        
        if let searchPhrase = searchPhrase {
            p["search"] = searchPhrase as AnyObject
        }
        
        if let discoverId = discoverId {
            p["discover"] = discoverId as AnyObject
        }
        
        if let username = username {
            p["profile"] = username as AnyObject
        }
        
        if let tag = tag {
            p["tags"] = tag as AnyObject
        }
        
        if let shoutTypeValue =  shoutType?.rawValue {
            p["shout_type"] = shoutTypeValue as AnyObject
        }
    
        if let category = category {
            p["category"] = category as AnyObject
        }
        
        if let minimumPrice = minimumPrice {
            p["min_price"] = minimumPrice as AnyObject
        }
        
        if let maximumPrice = maximumPrice {
            p["max_price"] = maximumPrice as AnyObject
        }
        
        if let sortType = sort?.type {
            p["sort"] = sortType as AnyObject
        }
        
        if let withinDistance = withinDistance {
            p["within"] = withinDistance as AnyObject
        }
        
        if self.excludeId != nil {
            p["exclude"] = self.excludeId as AnyObject
        }
        
        filters?.forEach({ (filter, values) in
            let valuesString = values.map{$0.slug}.joined(separator: ",")
            if valuesString.utf16.count > 0 {
                p[filter.slug] = valuesString as AnyObject
            }
        })
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        if passCountryOnly == true && self.country?.characters.count > 0 {
            p["country"] = self.country as AnyObject
        }
        
        if let skipLocation = self.skipLocation {
            if skipLocation == true {
                return p
            }
        }
        
        if attachCityAndState == true {
            p["city"] = self.city as AnyObject
            p["state"] = self.state as AnyObject
        }
        
        if entireCountry {
            p["country"] = self.country as AnyObject
        } else {
            for (key, value) in localizedParams {
                p[key] = value
            }
        }
        
        return p
    }
}
