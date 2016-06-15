//
//  Parsable.swift
//  shoutit
//
//  Created by Piotr Bernad on 03/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public protocol JSONReadable {
    
    associatedtype DecodedType = Self
    
    @warn_unused_result
    static func readFromJSON(json: AnyObject?) throws -> DecodedType
}

extension JSONReadable where Self: Decodable {
    
    static func fillWithJSON(json: AnyObject?) throws -> DecodedType {
        guard let json = json as? JSON else {
            throw JSONError.InvalidJSON
        }
        
        let result : Decoded<DecodedType> = self.decode(json)
        
        switch (result) {
        case .Success(let object):
            return object
        case .Failure(let erorr):
            throw erorr
        }
    }
}