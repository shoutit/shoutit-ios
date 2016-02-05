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
    private(set) var apns: String?
    private(set) var gcm: String?
}

extension PushTokens: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try apns <~> map["apns"]
        try gcm <~> map["gcm"]
    }
}