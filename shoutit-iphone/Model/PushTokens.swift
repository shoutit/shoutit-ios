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

public struct PushTokens {
    let apns: String?
    let gcm: String?
    
    public init(apns: String?, gcm: String?) {
            self.apns = apns
            self.gcm = gcm
    }
}

extension PushTokens: Decodable {
    
    public static func decode(j: JSON) -> Decoded<PushTokens> {
        return curry(PushTokens.init)
            <^> j <|? "apns"
            <*> j <|? "gcm"
    }
}

extension PushTokens: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "apns"    : self.apns.encode()
            ])
    }
}

extension PushTokens: Params {
    public var params: [String : AnyObject] {
        return self.encode().JSONObject() as! [String: AnyObject]
    }
}