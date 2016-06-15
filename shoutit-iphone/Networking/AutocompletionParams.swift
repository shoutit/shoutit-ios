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
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country
        }
    }
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["search"] = searchPhrase
        p["category"] = categoryName
        p["country"] = country
        
        return p
    }
}
