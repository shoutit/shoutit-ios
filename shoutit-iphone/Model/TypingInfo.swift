//
//  TypingInfo.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 27/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Curry
import Ogra

struct TypingInfo {
    let id: String
    let username: String
}

extension TypingInfo: Decodable {
    static func decode(j: JSON) -> Decoded<TypingInfo> {
        return curry(TypingInfo.init)
            <^> j <| "id"
            <*> j <| "username"
    }
}

extension TypingInfo: Encodable {
    func encode() -> JSON {
        return JSON.Object(["id": self.id.encode(),
            "username" : self.username.encode()])
    }
}