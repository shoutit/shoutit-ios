//
//  FilteredPagesParams.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct FilteredPagesParams: Params, PagedParams {
    public let page: Int?
    public let pageSize: Int?
    public let searchPhrase: String?
    public let country: String?
    
    public init(page: Int?, pageSize: Int?, searchPhrase: String? = nil, country: String?) {
        self.page = page
        self.pageSize = pageSize
        self.searchPhrase = searchPhrase
        self.country = country
    }
    
    public var params: [String : AnyObject] {
        var p = [String : AnyObject]()
        p["search"] = searchPhrase
        p["country"] = country
        for (key, value) in pagedParams {
            p[key] = value
        }
        return p
    }
}