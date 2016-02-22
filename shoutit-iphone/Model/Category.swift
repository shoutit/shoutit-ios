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

struct Category {
    let name: String
    let icon: String?
    let image: String?
    let slug: String
    let mainTag: Tag
}

extension Category: Decodable {
    
    static func decode(j: JSON) -> Decoded<Category> {
        return curry(Category.init)
            <^> j <| "name"
            <*> j <|? "icon"
            <*> j <|? "image"
            <*> j <| "slug"
            <*> j <| "main_tag"
    }
}

