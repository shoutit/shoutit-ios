//
//  Tag.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct Tag {
    let id: String
    let name: String
    let apiPath: String
    let imagePath: String
}

extension Tag: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract("id")
        name = try map.extract("name")
        apiPath = try map.extract("api_url")
        imagePath = try map.extract("image")
    }
    
    func sequence(map: Map) throws {
        try id ~> map["id"]
        try name ~> map["name"]
        try apiPath ~> map["api_url"]
        try imagePath ~> map["image"]
    }
}