//
//  SearchParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct SearchParams: Params, PagedParams {
    
    public let phrase: String
    public let page: Int?
    public let pageSize: Int?
    
    public var params: [String : AnyObject] {
        var p: [String : AnyObject] = ["search" : phrase]
        for (key, value) in pagedParams {
            p[key] = value
        }
        
        return p
    }
    
    public init(phrase: String, page: Int?, pageSize: Int?) {
        self.phrase = phrase
        self.page = page
        self.pageSize = pageSize
    }
}
