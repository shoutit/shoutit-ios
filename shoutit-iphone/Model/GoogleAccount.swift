//
//  GoogleAccount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct GoogleAccount {
    let gplusId: String
}

extension GoogleAccount: Decodable {
    
    public static func decode(j: JSON) -> Decoded<GoogleAccount> {
        return curry(GoogleAccount.init)
            <^> j <| "gplus_id"
    }
}

extension GoogleAccount: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "gplus_id" : self.gplusId.encode()
            ]
        )
    }
}