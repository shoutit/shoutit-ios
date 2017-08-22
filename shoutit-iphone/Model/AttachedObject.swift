//
//  AttachedObject.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct AttachedObject: Decodable {
    
    let profile : Profile?
    let shout : Shout?
    let message : Message?
    
    public static func decode(_ j: JSON) -> Decoded<AttachedObject> {
        return curry(AttachedObject.init)
            <^> j <|? "profile"
            <*> j <|? "shout"
            <*> j <|? "message"
    }
}
