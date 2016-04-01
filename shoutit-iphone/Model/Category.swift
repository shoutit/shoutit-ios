//
//  Category.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

struct Category: Hashable, Equatable {
    let name: String
    let icon: String?
    let image: String?
    let slug: String
    let filters: [Filter]?
    
    var hashValue: Int {
        get {
            return self.slug.hashValue
        }
    }
}

extension Category: Decodable {
    
    static func decode(j: JSON) -> Decoded<Category> {
        return curry(Category.init)
            <^> j <| "name"
            <*> j <|? "icon"
            <*> j <|? "image"
            <*> j <| "slug"
            <*> j <||? "filters"
        
    }
}


extension Category: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "slug"    : self.slug.encode() ])
    }
}

func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.slug == rhs.slug
}