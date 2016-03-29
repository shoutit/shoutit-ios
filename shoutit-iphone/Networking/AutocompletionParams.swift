//
//  AutocompletionParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct AutocompletionParams: Params {
    let searchPhrase: String
    let categoryName: String?
    let country: String?
    
    init(phrase: String, categoryName: String?, country: String?, useLocaleBasedCountryCodeWhenNil: Bool = false) {
        self.searchPhrase = phrase
        self.categoryName = categoryName
        if country == nil && useLocaleBasedCountryCodeWhenNil {
            self.country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        } else {
            self.country = country
        }
    }
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["search"] = searchPhrase
        p["category"] = categoryName
        p["country"] = country
        
        return p
    }
}
