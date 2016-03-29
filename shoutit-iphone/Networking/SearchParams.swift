//
//  SearchParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct SearchParams: Params, PagedParams {
    
    let phrase: String
    let page: Int?
    let pageSize: Int?
    
    var params: [String : AnyObject] {
        var p: [String : AnyObject] = ["search" : phrase]
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        return p
    }
}
