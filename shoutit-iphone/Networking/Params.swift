//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Ogra

public protocol Params {
    var params: [String : AnyObject] {get}
}

public protocol PagedParams {
    var page: Int? {get}
    var pageSize: Int? {get}
}

extension PagedParams {
    public var pagedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["page"] = page
        p["page_size"] = pageSize
        return p
    }
}

public protocol LocalizedParams {
    var country: String? {get}
}

extension LocalizedParams {
    public var localizedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["country"] = country
        return p

    }
}

public struct NopParams: Params {
    
    public init?() {
        return nil
    }
    
    public var params: [String : AnyObject] {
        return [:]
    }
}
