//
//  Display.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct DisplayRange: Decodable {
    let offset: Int
    let length: Int
    
    public static func decode(j: JSON) -> Decoded<DisplayRange> {
        let a = curry(DisplayRange.init)
            <^> j <| "offset"
            <*> j <| "length"
        
        return a
    }
}

public struct Display: Decodable {
    let text: String
    var ranges: [DisplayRange]?
    let image: String?
    
    
    public static func decode(j: JSON) -> Decoded<Display> {
        let a = curry(Display.init)
            <^> j <| "text"
            <*> j <||? "ranges"
            <*> j <|? "image"        
        
        return a
    }
    
}
