//
//  APNParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Ogra

public struct APNParams: Params {
    public let tokens: PushTokens
    
    public var params: [String : AnyObject] {
        return ["push_tokens" : self.tokens.encode().JSONObject()]
    }
    
    public init(tokens: PushTokens) {
        self.tokens = tokens
    }
}
