//
//  RelatedShoutsParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct RelatedShoutsParams: Params, PagedParams {
    
    public let shout: Shout
    public let page: Int?
    public let pageSize: Int?
    
    public init(shout: Shout, page: Int?, pageSize: Int?) {
        self.shout = shout
        self.page = page
        self.pageSize = pageSize
    }
    
    public var params: [String : AnyObject] {
        var params: [String : AnyObject] = [:]
        
        for (key, value) in pagedParams {
            params[key] = value
        }
        
        return params
    }
}
