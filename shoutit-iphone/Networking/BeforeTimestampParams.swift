//
//  BeforeTimestampParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct BeforeTimestampParams: Params {
    
    public var beforeTimeStamp : Int?
    
    public var params: [String : AnyObject] {
        if let after = self.beforeTimeStamp {
            return ["before":after, "page_size":20]
        }
        
        return [:]
    }
    
    public init(beforeTimeStamp: Int?) {
        self.beforeTimeStamp = beforeTimeStamp
    }
}
