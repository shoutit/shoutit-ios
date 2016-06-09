//
//  Category.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Ogra

public struct Category: Hashable, Equatable {
    public let name: String
    public let icon: String?
    public let image: String?
    public let slug: String
    public let filters: [Filter]?
    
    public var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension Category: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Category> {
        return curry(Category.init)
            <^> j <| "name"
            <*> j <|? "icon"
            <*> j <|? "image"
            <*> j <| "slug"
            <*> j <||? "filters"
        
    }
}


extension Category: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "slug"    : self.slug.encode() ])
    }
}

public func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.slug == rhs.slug
}