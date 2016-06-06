//
//  SuggesttionsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct SuggestionsParams: Params {
    
    public init(address: Address, pageSize: Int, type: SuggestionsTypes, page: Int) {
        self.pageSize = pageSize
        self.country = address.country
        self.state = address.state
        self.city = address.city
        self.type = type
        self.page = page
    }
    
    public let pageSize: Int
    public let country: String
    public let state: String
    public let city: String
    public let type: SuggestionsTypes
    public let page: Int
    
    public var params: [String : AnyObject] {
        return [
            "type" : type.parameters(),
            "page_size" : pageSize,
            "country" : country,
            "state" : state,
            "city" : city,
            "page" : page
        ]
    }
}

public struct SuggestionsTypes: OptionSetType {
    
    public let rawValue: Int
    
    public static let None = SuggestionsTypes(rawValue: 0)
    public static let Users = SuggestionsTypes(rawValue: 1 << 0)
    public static let Pages = SuggestionsTypes(rawValue: 1 << 1)
    public static let Tags = SuggestionsTypes(rawValue: 1 << 2)
    public static let Shouts = SuggestionsTypes(rawValue: 1 << 3)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public func parameters() -> String {
        
        var params = ""
        if self.contains(.Users) {
            params += "users"
        }
        if self.contains(.Pages) {
            if !params.isEmpty {
                params += ","
            }
            params += "pages"
        }
        if self.contains(.Tags) {
            if !params.isEmpty {
                params += ","
            }
            params += "tags"
        }
        if self.contains(.Shouts) {
            if !params.isEmpty {
                params += ","
            }
            params += "shouts"
        }
        
        return params
    }
}