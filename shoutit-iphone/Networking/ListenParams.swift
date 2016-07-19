//
//  ListenParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 10.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct BatchListenParams: Params {
    
    public let tagSlugs: [String]
    
    public var params: [String : AnyObject] {
        return [
            "tags" : tagSlugs.map{["slug" : $0]}
        ]
    }
    
    public init(tagSlugs: [String]) {
        self.tagSlugs = tagSlugs
    }
}