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
    
    
    static func readFromJSON(_ json: AnyObject?) throws -> DecodedType
}

extension JSONReadable where Self: Decodable {
    
    static func fillWithJSON(_ json: AnyObject?) throws -> DecodedType {
        guard let json = json as? JSON else {
            throw JSONError.invalidJSON
        }
        
        let result : Decoded<DecodedType> = self.decode(json)
        
        switch (result) {
        case .success(let object):
            return object
        case .failure(let erorr):
            throw erorr
        }
    }
}
