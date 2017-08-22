//
//  ConversationsListParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct ConversationsListParams: Params {
    public let pageSize : Int
    public var conversationType: ConversationType? = nil
    public var beforeTimestamp: Int? = nil
    public var afterTimestamp: Int? = nil
    
    public var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        params["page_size"] = pageSize as AnyObject
        params["type"] = conversationType?.rawValue as AnyObject
        params["before"] = beforeTimestamp as AnyObject
        params["after"] = afterTimestamp as AnyObject
        return params
    }
    
    public init(pageSize: Int, conversationType: ConversationType? = nil, beforeTimestamp: Int? = nil, afterTimestamp: Int? = nil) {
        self.pageSize = pageSize
        self.conversationType = conversationType
        self.beforeTimestamp = beforeTimestamp
        self.afterTimestamp = afterTimestamp
    }
}
