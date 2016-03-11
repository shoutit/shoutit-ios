//
//  Success.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Success {
    let message: String
}

extension Success: Decodable {
    static func decode(j: JSON) -> Decoded<Success> {
        return curry(Success.init)
            <^> j <| "success"
    }
}


