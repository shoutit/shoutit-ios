//
//  MiniProfile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct MiniProfile {
    let id: String
    let username: String
    let name: String?
}

extension MiniProfile: Decodable {
    
    static func decode(j: JSON) -> Decoded<MiniProfile> {
        return curry(MiniProfile.init)
            <^> j <| "id"
            <*> j <| "username"
            <*> j <|? "name"
    }
}
