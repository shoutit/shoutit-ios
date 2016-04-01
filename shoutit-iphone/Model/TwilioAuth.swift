//
//  TwilioAuth.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct TwilioAuth {
    let token: String
    let identity: String
}

extension TwilioAuth: Decodable {
    static func decode(j: JSON) -> Decoded<TwilioAuth> {
        return curry(TwilioAuth.init)
            <^> j <| "token"
            <*> j <| "identity"
    }
}

extension TwilioAuth: Encodable {
    func encode() -> JSON {
        return JSON.Object(["token": self.token.encode(),
            "identity" : self.identity.encode()])
    }
}

struct TwilioIdentity {
    let identity: String
}

extension TwilioIdentity: Decodable {
    static func decode(j: JSON) -> Decoded<TwilioIdentity> {
        return curry(TwilioIdentity.init)
            <^> j <| "identity"
    }
}

extension TwilioIdentity: Encodable {
    func encode() -> JSON {
        return JSON.Object(["identity" : self.identity.encode()])
    }
}