//
//  LoginAccounts.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct LoginAccounts {
    let gplus: Bool
    let facebook: Bool
}

extension LoginAccounts: MappableObject {
    
    init(map: Map) throws {
        gplus = try map.extract("gplus")
        facebook = try map.extract("facebook")
    }
    
    func sequence(map: Map) throws {
        try gplus                ~> map["gplus"]
        try facebook             ~> map["facebook"]
    }
}