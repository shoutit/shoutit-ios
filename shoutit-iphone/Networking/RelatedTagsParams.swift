//
//  RelatedTagsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct RelatedTagsParams: Params, PagedParams, LocalizedParams {
    
    public let tagSlug: String
    public let pageSize: Int?
    public let page: Int?
    public let category: String?
    public let country: String?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["category"] = category as AnyObject
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        for (key, value) in localizedParams {
            p[key] = value
        }
        
        return p
    }
    
    public init(tagSlug: String, pageSize: Int?, page: Int?, category: String?, country: String?) {
        self.tagSlug = tagSlug
        self.pageSize = pageSize
        self.page = page
        self.category = category
        self.country = country
    }
}
