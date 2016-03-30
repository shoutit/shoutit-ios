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

struct Mobile {
    let phone: String
}

extension Mobile: Decodable {
    
    static func decode(j: JSON) -> Decoded<Mobile> {
        return curry(Mobile.init)
            <^> j <| "mobile"
    }
}
