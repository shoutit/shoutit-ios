//
//  MessageParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct MessageParams: Params {
    let message: Message
    
    init(message: Message) {
        self.message = message
    }
    
    var params: [String : AnyObject] {
        return self.message.encode().JSONObject() as! [String: AnyObject]
    }
}
