//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol Params {
    var params: [String : AnyObject] {get}
}

struct NopParams: Params {
    
    init?() {
        return nil
    }
    
    var params: [String : AnyObject] {
        return [:]
    }
}

struct PageParams: Params {
    var page : Int
    var pageSize : Int
    
    var params: [String : AnyObject] {
        return ["page":self.page, "page_size": self.pageSize]
    }
}
