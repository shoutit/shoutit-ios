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

public struct MiniProfile {
    public let id: String
    public let username: String
    public let name: String?
    
    public init (id: String, username: String, name: String?) {
        self.id = id
        self.username = username
        self.name = name
    }
}

extension MiniProfile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<MiniProfile> {
        return curry(MiniProfile.init)
            <^> j <| "id"
            <*> j <| "username"
            <*> j <|? "name"
    }
}
