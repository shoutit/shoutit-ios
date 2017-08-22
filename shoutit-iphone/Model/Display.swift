//
//  Display.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct DisplayRange: Decodable {
    public let offset: Int
    public let length: Int
    
    public static func decode(_ j: JSON) -> Decoded<DisplayRange> {
        let a = curry(DisplayRange.init)
            <^> j <| "offset"
            <*> j <| "length"
        
        return a
    }
}

public struct Display: Decodable {
    public let text: String
    public var ranges: [DisplayRange]?
    public let image: String?
    
    
    public static func decode(_ j: JSON) -> Decoded<Display> {
        let a = curry(Display.init)
            <^> j <| "text"
            <*> j <||? "ranges"
            <*> j <|? "image"        
        
        return a
    }
}
