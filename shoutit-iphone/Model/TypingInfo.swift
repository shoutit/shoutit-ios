//
//  TypingInfo.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 27/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo

import Ogra

public struct TypingInfo {
    public let id: String
    public let username: String
    
    public init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}

extension TypingInfo: Decodable {
    public static func decode(_ j: JSON) -> Decoded<TypingInfo> {
        return curry(TypingInfo.init)
            <^> j <| "id"
            <*> j <| "username"
    }
}

extension TypingInfo: Encodable {
    public func encode() -> JSON {
        return JSON.object(["id": self.id.encode(),
            "username" : self.username.encode()])
    }
}
