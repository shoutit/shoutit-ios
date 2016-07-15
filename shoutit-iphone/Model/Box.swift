//
//  Box.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public final class Box<T: Decodable where T: Encodable, T.DecodedType == T> : Decodable, Encodable {
    public var value: T
    public init(_ value: T) {
        self.value = value
    }
    
    public static func decode(j: JSON) -> Decoded<Box<T>> {
        let value : Decoded<T.DecodedType> = T.decode(j)

        switch value {
        case .Success(let val):
            return Decoded.Success(Box(val))
        case .Failure(let error):
            return Decoded.Failure(error)
        }
    }
    
    public func encode() -> JSON {
        return value.encode()
    }
}
