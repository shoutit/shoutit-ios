//
//  Category.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct Category {
    let name: String
    let slug: String
    let mainTag: Tag
}

extension Category: MappableObject {
    
    init(map: Map) throws {
        name = try map.extract("name")
        slug = try map.extract("slug")
        mainTag = try map.extract("main_tag")
    }
}
