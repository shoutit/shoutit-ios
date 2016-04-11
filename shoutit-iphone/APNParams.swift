//
//  APNParams.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Ogra

struct APNParams: Params {
    let tokens: PushTokens
    
    var params: [String : AnyObject] {
        return ["push_tokens" : self.tokens.encode().JSONObject()]
    }
}
