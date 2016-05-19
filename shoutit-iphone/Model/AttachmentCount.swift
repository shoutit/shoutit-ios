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

struct AttachmentCount {
    let shout: Int
    let media: Int
    let profile: Int
    let location: Int
    
    static var zeroCount: AttachmentCount {
        return AttachmentCount(shout: 0,
                               media: 0,
                               profile: 0,
                               location: 0)
    }
}

extension AttachmentCount: Decodable {
    
    static func decode(j: JSON) -> Decoded<AttachmentCount> {
        return curry(AttachmentCount.init)
            <^> j <| "shout"
            <*> j <| "media"
            <*> j <| "profile"
            <*> j <| "location"
    }
}
