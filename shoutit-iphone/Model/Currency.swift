//
//  Currency.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct Currency {
    
    let code: String
    let country: String
    let name: String
}


extension Currency: Decodable {
    
    static func decode(j: JSON) -> Decoded<Currency> {
        let f = curry(Currency.init)
            <^> j <| "code"
            <*> j <| "country"
            <*> j <| "name"
        return f
    }
}

extension Currency: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "code"    : self.code.encode(),
            "country"  : self.country.encode(),
            "name" : self.name.encode()
            ])
    }
}