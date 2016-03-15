//
//  RelatedShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct RelatedShoutsParams: Params, PagedParams {
    
    let shout: Shout
    let page: Int?
    let pageSize: Int?
    let type: ShoutType?
    
    var params: [String : AnyObject] {
        var params: [String : AnyObject] = [
            "id" : shout.id,
            "shout_type" : type?.rawValue ?? "all",
        ]
        
        for (key, value) in pagedParams {
            params[key] = value
        }
        
        return params
    }
}
