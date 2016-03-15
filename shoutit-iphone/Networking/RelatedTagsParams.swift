//
//  RelatedTagsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct RelatedTagsParams: Params, PagedParams, LocalizedParams {
    
    let tagName: String
    let pageSize: Int?
    let page: Int?
    let category: String?
    let city: String?
    let state: String?
    let country: String?
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["category"] = category
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        for (key, value) in localizedParams {
            p[key] = value
        }
        
        return p
    }
}
