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

public final class Box<T: Decodable> : Decodable, Encodable where T: Encodable, T.DecodedType == T {
    public var value: T
    public init(_ value: T) {
        self.value = value
    }
    
    public static func decode(_ j: JSON) -> Decoded<Box<T>> {
        let value : Decoded<T.DecodedType> = T.decode(j)

        switch value {
        case .success(let val):
            return Decoded.success(Box(val))
        case .failure(let error):
            return Decoded.failure(error)
        }
    }
    
    public func encode() -> JSON {
        return value.encode()
    }
}
