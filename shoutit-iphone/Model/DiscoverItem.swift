//
//  DiscoverItem.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct DiscoverItem {
    let id: String?
    let apiUrl: String?
    let title: String?
    let subtitle: String?
    let position: Int?
    let image: String?
    let icon: String?
    let description: String?
    let cover: String?
    let parents: [DiscoverItem]?
    let children: [DiscoverItem]?
    let shoutsUrl: String?

    
}

extension DiscoverItem: MappableObject {
    init(map: Map) throws {
        id = try map.extract("id")
        apiUrl = try map.extract("apiUrl")
        title = try map.extract("title")
        subtitle = try map.extract("subtitle")
        position = try map.extract("position")
        image = try map.extract("image")
        icon = try map.extract("icon")
        description = try map.extract("description")
        cover = try map.extract("cover")
        parents = try map.extract("parents")
        children = try map.extract("children")
        shoutsUrl = try map.extract("shoutsUrl")
    }
}
