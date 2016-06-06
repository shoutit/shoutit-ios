//
//  Mobile.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 30.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct Mobile {
    let phone: String
}

extension Mobile: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Mobile> {
        return curry(Mobile.init)
            <^> j <| "mobile"
    }
}
