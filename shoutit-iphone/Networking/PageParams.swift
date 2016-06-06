//
//  PageParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct PageParams: Params {
    public var page : Int
    public var pageSize : Int
    
    public var params: [String : AnyObject] {
        return ["page":self.page, "page_size": self.pageSize]
    }
    
    public init(page: Int, pageSize: Int) {
        self.page = page
        self.pageSize = pageSize
    }
}
