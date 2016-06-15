//
//  TwilioAuth.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

import Ogra

public struct TwilioAuth {
    public let token: String
    public let identity: String
}

extension TwilioAuth: Decodable {
    public static func decode(j: JSON) -> Decoded<TwilioAuth> {
        return curry(TwilioAuth.init)
            <^> j <| "token"
            <*> j <| "identity"
    }
}

extension TwilioAuth: Encodable {
    public func encode() -> JSON {
        return JSON.Object(["token": self.token.encode(),
            "identity" : self.identity.encode()])
    }
}

public struct TwilioIdentity {
    public let identity: String

    public init(identity: String) {
        self.identity = identity
    }
}

extension TwilioIdentity: Decodable {
    public static func decode(j: JSON) -> Decoded<TwilioIdentity> {
        return curry(TwilioIdentity.init)
            <^> j <| "identity"
    }
}

extension TwilioIdentity: Encodable {
    public func encode() -> JSON {
        return JSON.Object(["identity" : self.identity.encode()])
    }
}