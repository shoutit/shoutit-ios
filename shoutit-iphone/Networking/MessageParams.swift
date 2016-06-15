//
//  MessageParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public struct MessageParams: Params {
    let message: Message
    
    public init(message: Message) {
        self.message = message
    }
    
    public var params: [String : AnyObject] {
        return self.message.encode().JSONObject() as! [String: AnyObject]
    }
}
