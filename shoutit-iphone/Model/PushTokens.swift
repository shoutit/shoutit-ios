//
//  PushTokens.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct PushTokens {
    let apns: String?
    let gcm: String?
}

extension PushTokens: Decodable {
    
    static func decode(j: JSON) -> Decoded<PushTokens> {
        return curry(PushTokens.init)
            <^> j <|? "apns"
            <*> j <|? "gcm"
    }
}

extension PushTokens: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "apns"    : self.apns.encode(),
            "gcm"  : self.gcm.encode()
            ])
    }
}

extension PushTokens: Params {
    var params: [String : AnyObject] {
        return self.encode().JSONObject() as! [String: AnyObject]
    }
}