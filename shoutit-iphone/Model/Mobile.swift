//
//  Mobile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 30.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct Mobile {
    public let phone: String
    public init(phone: String) {
        self.phone = phone
    }
}

extension Mobile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Mobile> {
        return curry(Mobile.init)
            <^> j <| "mobile"
    }
}
