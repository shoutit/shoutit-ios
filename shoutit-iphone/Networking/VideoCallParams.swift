//
//  VideoCallParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct VideoCallParams: Params {
    let identity: String
    let missed: Bool
    
    public init(identity: String, missed: Bool) {
        self.identity = identity
        self.missed = missed
    }
    
    public var params: [String : AnyObject] {
        return ["identity" : identity as AnyObject,
                "missed" : missed as AnyObject]
    }
}
