//
//  FBNativeAdExtension.swift
//  shoutit
//
//  Created by Piotr Bernad on 07/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import FBAudienceNetwork
import Argo
import Ogra

extension FBNativeAd : Decodable, Encodable {
    public func encode() -> JSON {
        return JSON.Object(["fake": "object".encode()])
    }
    
    public static func decode(j: JSON) -> Decoded<FBNativeAd> {
        let decoded : Decoded<FBNativeAd> = .Success(FBNativeAd(placementID: ""))
        return decoded
    }   
}