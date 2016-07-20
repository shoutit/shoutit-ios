//
//  FacebookPage.swift
//  shoutit
//
//  Created by Piotr Bernad on 20/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct FacebookPage {
    public let perms: [String]
    public let facebookId: String
    public let name: String
}

extension FacebookPage: Decodable {
    
    public static func decode(j: JSON) -> Decoded<FacebookPage> {
        return curry(FacebookPage.init)
            <^> j <|| "perms"
            <*> j <| "facebook_id"
            <*> j <| "name"
    }
}

extension FacebookPage: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "perms"    : perms.encode(),
            "facebook_id"  : facebookId.encode(),
            "name" : name.encode()
            ]
        )
    }
}