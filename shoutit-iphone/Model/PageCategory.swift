//
//  PageCategory.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct PageCategory: Hashable, Equatable {
    public let name: String
    public let icon: String?
    public let image: String?
    public let slug: String
    public let children: [PageCategory]?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension PageCategory: Decodable {
    
    public static func decode(j: JSON) -> Decoded<PageCategory> {
        return curry(PageCategory.init)
            <^> j <| "name"
            <*> j <|? "icon"
            <*> j <|? "image"
            <*> j <| "slug"
            <*> j <||? "children"
        
    }
}


extension PageCategory: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "slug"    : self.slug.encode() ])
    }
}

public func ==(lhs: PageCategory, rhs: PageCategory) -> Bool {
    return lhs.slug == rhs.slug
}