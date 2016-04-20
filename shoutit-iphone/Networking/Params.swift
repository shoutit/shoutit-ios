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
        p["city"] = state
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

struct PageParams: Params {
    var page : Int
    var pageSize : Int
    
    var params: [String : AnyObject] {
        return ["page":self.page, "page_size": self.pageSize]
    }
}

struct AfterParams: Params {
    var afterTimeStamp : Int?
    
    var params: [String : AnyObject] {
        if let after = self.afterTimeStamp {
            return ["before":after, "page_size":20]
        }
        
        return [:]
    }
}


struct MessageParams: Params {
    let message: Message
    
    init(message: Message) {
        self.message = message
    }
    
    var params: [String : AnyObject] {
        return self.message.encode().JSONObject() as! [String: AnyObject]
    }
}

struct MissedCallParams: Params {
    let identity: String
    
    init(identity: String) {
        self.identity = identity
    }
    
    var params: [String : AnyObject] {
        return ["identity": self.identity, "missed": true]
    }
}
