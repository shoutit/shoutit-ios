//
//  AutocompletionParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct AutocompletionParams: Params {
    public let searchPhrase: String
    public let categoryName: String?
    public let country: String?
    
    public init(phrase: String, categoryName: String?, country: String?, useLocaleBasedCountryCodeWhenNil: Bool = false) {
        self.searchPhrase = phrase
        self.categoryName = categoryName
        if country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
        } else {
            self.country = country
        }
    }
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["search"] = searchPhrase as AnyObject
        p["category"] = categoryName as AnyObject
        p["country"] = country as AnyObject
        
        return p
    }
}
