//
//  AttachmentCount.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 19.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct AttachmentCount {
    public let shout: Int
    public let media: Int
    public let profile: Int
    public let location: Int
    
    public static var zeroCount: AttachmentCount {
        return AttachmentCount(shout: 0,
                               media: 0,
                               profile: 0,
                               location: 0)
    }
}

extension AttachmentCount: Decodable {
    
    public static func decode(j: JSON) -> Decoded<AttachmentCount> {
        return curry(AttachmentCount.init)
            <^> j <| "shout"
            <*> j <| "media"
            <*> j <| "profile"
            <*> j <| "location"
    }
}
