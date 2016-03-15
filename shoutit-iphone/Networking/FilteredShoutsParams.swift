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
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        
        p["tags"] = tag
        
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        for (key, value) in localizedParams {
            p[key] = value
        }
        
        return p
    }
}
