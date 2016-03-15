//
//  ReadBy.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct ReadBy: Decodable, Hashable, Equatable {
    let profileId: String
    let readAt: Int
    
    var hashValue: Int {
        get {
            return self.profileId.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<ReadBy> {
        return curry(ReadBy.init)
            <^> j <| "profile_id"
            <*> j <| "read_at"
    }
}

func ==(lhs: ReadBy, rhs: ReadBy) -> Bool {
    return lhs.profileId == rhs.profileId
}