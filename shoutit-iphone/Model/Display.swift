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

struct DisplayRange: Decodable {
    let offset: Int
    let length: Int
    
    static func decode(j: JSON) -> Decoded<DisplayRange> {
        let a = curry(DisplayRange.init)
            <^> j <| "offset"
            <*> j <| "length"
        
        return a
    }
}

struct Display: Decodable {
    let text: String
    var ranges: [DisplayRange]?
    let image: String?
    let webPath: String?
    let appPath: String?
    
    static func decode(j: JSON) -> Decoded<Display> {
        let a = curry(Display.init)
            <^> j <| "text"
            <*> j <||? "ranges"
            <*> j <|? "image"
        let b = a
            <*> j <|? "web_url"
            <*> j <|? "app_url"
        
        return b
    }
    
}
