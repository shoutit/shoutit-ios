//
//  RelatedShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct RelatedShoutsParams: Params {
    
    let shout: Shout
    let page: Int
    let pageSize: Int
    let type: ShoutType?
    
    var params: [String : AnyObject] {
        return [
            "id" : shout.id,
            "shout_type" : type?.rawValue ?? "all",
            "page" : page,
            "page_size" : pageSize
        ]
    }
}
