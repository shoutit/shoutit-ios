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
    let message: String
}

extension Success: MappableObject {
    
    init(map: Map) throws {
        message = try map.extract("success")
    }
}


