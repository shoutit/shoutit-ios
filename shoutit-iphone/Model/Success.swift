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

public struct Success {
    public let message: String
}

extension Success: Decodable {
    public static func decode(j: JSON) -> Decoded<Success> {
        return curry(Success.init)
            <^> j <| "success"
    }
}


