//
//  ListenParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct BatchListenParams: Params {
    
    public let tagNames: [String]
    
    public var params: [String : AnyObject] {
        return [
            "tags" : tagNames.map{["name" : $0]}
        ]
    }
    
    public init(tagNames: [String]) {
        self.tagNames = tagNames
    }
}