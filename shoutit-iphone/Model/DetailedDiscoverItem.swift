//
//  DetailedDiscoverItem.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct DetailedDiscoverItem {
    public let id: String
    public let apiUrl: String
    public let title: String
    public let subtitle: String?
    public let position: Int
    public let image: String?
    public let cover: String?
    public let icon: String?
    public let showChildren: Bool
    public let children: [DiscoverItem]
    public let showShouts: Bool
    public let shoutsPath: String?
    
    public func simpleForm() -> DiscoverItem {
        return DiscoverItem(id: id, apiUrl: apiUrl, title: title, subtitle: subtitle, position: position, image: image, cover: cover, icon: icon)
    }
}

extension DetailedDiscoverItem: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        apiUrl = try decoder.decode("api_url")
        title = try decoder.decode("title")
        subtitle = try decoder.decode("subtitle")
        position = try decoder.decode("position")
        image = try decoder.decode("image")
        cover = try decoder.decode("cover")
        icon = try decoder.decode("icon")
        showChildren = try decoder.decode("show_children")
        children = try decoder.decode("children")
        showShouts = try decoder.decode("show_shouts")
        shoutsPath = try decoder.decode("shouts_url")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(apiUrl, key: "api_url")
            try encoder.encode(title, key: "title")
            try encoder.encode(subtitle, key: "subtitle")
            try encoder.encode(position, key: "position")
            try encoder.encode(image, key: "image")
            try encoder.encode(cover, key: "cover")
            try encoder.encode(icon, key: "icon")
            try encoder.encode(showChildren, key: "show_children")
            try encoder.encode(children, key: "children")
            try encoder.encode(showShouts, key: "show_shouts")
            try encoder.encode(shoutsPath, key: "shouts_url")
        })
    }
}

extension DetailedDiscoverItem: Hashable, Equatable {
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
}

public func ==(lhs: DetailedDiscoverItem, rhs: DetailedDiscoverItem) -> Bool {
    return lhs.id == rhs.id
}
