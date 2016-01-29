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
    
    private(set) var gplus: Bool = false
    private(set) var facebook: Bool = false
}

extension LoginAccounts: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try gplus                <~ map["gplus"]
        try facebook             <~ map["facebook"]
    }
}