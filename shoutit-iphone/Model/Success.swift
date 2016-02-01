//
//  Success.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct Success {
    private(set) var message: String = ""
}

extension Success: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try message <~ map["success"]
    }
}


