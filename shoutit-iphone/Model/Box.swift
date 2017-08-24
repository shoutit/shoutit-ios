//
//  Box.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public final class Box<T> : JSONCodable where T: JSONCodable {
    public var value: T
    public init(_ value: T) {
        self.value = value
    }
    
    public init(object: JSONObject) throws {
        value = try T(object: object)
    }
    
    public func toJSON() throws -> Any {
        return try value.toJSON()
    }
    
}
