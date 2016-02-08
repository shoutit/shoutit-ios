//
//  ListenersMetadata.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct ListenersMetadata {
    let pages: Int
    let users: Int
    let tags: Int
}

extension ListenersMetadata: MappableObject {
    
    init(map: Map) throws {
        pages = try map.extract("pages")
        users = try map.extract("users")
        tags = try map.extract("tags")
    }
    
    func sequence(map: Map) throws {
        try pages                   ~> map["pages"]
        try users                   ~> map["users"]
        try tags                    ~> map["tags"]
    }
}
