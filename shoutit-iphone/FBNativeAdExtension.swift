//
//  FBNativeAdExtension.swift
//  shoutit
//
//  Created by Piotr Bernad on 07/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import FBAudienceNetwork
import JSONCodable

extension FBNativeAd: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
        })
    }
}

