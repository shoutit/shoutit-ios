//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Ogra

protocol Params {
    var params: [String : AnyObject] {get}
}

protocol PagedParams {
    var page: Int? {get}
    var pageSize: Int? {get}
}

extension PagedParams {
    var pagedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["page"] = page
        p["page_size"] = pageSize
        return p
    }
}

protocol LocalizedParams {
    var country: String? {get}
    var state: String? {get}
    var city: String? {get}
}

extension LocalizedParams {
    var localizedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["country"] = country
        p["state"] = state
        p["city"] = city
        return p

    }
}

struct NopParams: Params {
    
    init?() {
        return nil
    }
    
    var params: [String : AnyObject] {
        return [:]
    }
}
