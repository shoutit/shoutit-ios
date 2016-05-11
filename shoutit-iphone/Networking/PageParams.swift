//
//  PageParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct PageParams: Params {
    var page : Int
    var pageSize : Int
    
    var params: [String : AnyObject] {
        return ["page":self.page, "page_size": self.pageSize]
    }
}
