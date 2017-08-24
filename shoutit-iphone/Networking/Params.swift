//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Ogra
import JSONCodable

public protocol Params {
    var params: [String : AnyObject] {get}
}

extension Params where Self: JSONEncodable {
    public var params: [String : AnyObject] {
        
        return try! self.toJSON() as! [String: AnyObject]
    }
}

public protocol PagedParams {
    var page: Int? {get}
    var pageSize: Int? {get}
}

extension PagedParams {
    public var pagedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["page"] = page as AnyObject
        p["page_size"] = pageSize as AnyObject
        return p
    }
}

public protocol LocalizedParams {
    var country: String? {get}
}

extension LocalizedParams {
    public var localizedParams: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["country"] = country as AnyObject
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
