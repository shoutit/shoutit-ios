//
//  Suggestions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct Suggestions {
    let users: [Profile]
    let pages: [Profile]
    let tags: [Tag]
    let shouts: [Shout]
}

extension Suggestions: MappableObject {
    
    init(map: Map) throws {
        users = try map.extract("users")
        pages = try map.extract("pages")
        tags = try map.extract("tags")
        shouts = try map.extract("shouts")
    }
}
