//
//  PushTokens.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct PushTokens {
    let apns: String?
    let gcm: String?
}

extension PushTokens: MappableObject {
    
    init(map: Map) throws {
        apns = try map.extract("apns")
        gcm = try map.extract("gcm")
    }
    
    func sequence(map: Map) throws {
        try apns ~> map["apns"]
        try gcm ~> map["gcm"]
    }
}