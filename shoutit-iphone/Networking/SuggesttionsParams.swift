//
//  SuggesttionsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct SuggestionsParams: Params {
    
    init(address: Address, pageSize: Int, type: SuggestionsTypes) {
        self.pageSize = pageSize
        self.country = address.country
        self.state = address.state
        self.city = address.city
        self.type = type
    }
    
    let pageSize: Int
    let country: String
    let state: String
    let city: String
    let type: SuggestionsTypes
    
    var params: [String : AnyObject] {
        return [
            "type" : type.parameters(),
            "country" : country,
            "state" : state,
            "city" : city
        ]
    }
}

struct SuggestionsTypes: OptionSetType {
    
    let rawValue: Int
    
    static let None = SuggestionsTypes(rawValue: 0)
    static let Users = SuggestionsTypes(rawValue: 1 << 0)
    static let Pages = SuggestionsTypes(rawValue: 1 << 1)
    static let Tags = SuggestionsTypes(rawValue: 1 << 2)
    static let Shouts = SuggestionsTypes(rawValue: 1 << 3)
    
    func parameters() -> [String] {
        
        var array = [String]()
        if self.contains(.Users) {
            array.append("users")
        }
        if self.contains(.Pages) {
            array.append("pages")
        }
        if self.contains(.Tags) {
            array.append("tags")
        }
        if self.contains(.Shouts) {
            array.append("shouts")
        }
        
        return array
    }
}