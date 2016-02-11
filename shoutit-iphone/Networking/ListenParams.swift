//
//  ListenParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct BatchListenParams: Params {
    
    let tagNames: [String]
    
    var params: [String : AnyObject] {
        return [
            "tags" : tagNames.map{["name" : $0]}
        ]
    }
}