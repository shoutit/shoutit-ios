//
//  JSONWriteable.swift
//  shoutit
//
//  Created by Piotr Bernad on 03/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public protocol JSONWriteable {
        
    @warn_unused_result
    func asJSON() throws -> AnyObject
}

extension JSONReadable where Self: Encodable {
    func asJSON() throws -> AnyObject {
        guard let json = self.encode() as? AnyObject else {
            throw JSONError.InvalidJSON
        }
        
        return json
    }
}