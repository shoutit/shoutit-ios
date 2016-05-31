//
//  VideoCallParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct VideoCallParams: Params {
    let identity: String
    let missed: Bool
    
    init(identity: String, missed: Bool) {
        self.identity = identity
        self.missed = missed
    }
    
    var params: [String : AnyObject] {
        return ["identity" : identity,
                "missed" : missed]
    }
}
