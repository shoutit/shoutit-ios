//
//  Params.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public protocol Params {
    var params: [String : AnyObject] {get}
}

public struct JSONParams: Params {
    public init(_ object: JSONEncodable) {
        self.p = (try? object.toJSON() as! [String: AnyObject]) ?? [String: AnyObject]()
    }
    
    public init(_ object: JSONObject) {
        self.p = object as [String: AnyObject]
    }
    
    private let p: [String: AnyObject]
    
    public var params: [String : AnyObject] {
        return p
    }
}


extension JSONEncodable {
    public var params: JSONParams {
        return JSONParams(self)
    }
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
