//
//  Box.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

final class Box<T: Decodable where T.DecodedType == T>  : Decodable {
    var value: T
    init(_ value: T) {
        self.value = value
    }
    
    static func decode(j: JSON) -> Decoded<Box<T>> {
        let value : Decoded<T.DecodedType> = T.decode(j)

        switch value {

        case .Success(let val):
                return Decoded.Success(Box(val))
        case .Failure(let error):
                return Decoded.Failure(error)
            
        }
    }
}
