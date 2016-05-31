//
//  ConversationsListParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct ConversationsListParams: Params {
    let pageSize : Int
    let conversationType: ConversationType? = nil
    let beforeTimestamp: Int? = nil
    let afterTimestamp: Int? = nil
    
    var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        params["page_size"] = pageSize
        params["type"] = conversationType?.rawValue
        params["before"] = beforeTimestamp
        params["after"] = afterTimestamp
        return params
    }
}
