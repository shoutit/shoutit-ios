//
//  DiscoverItem.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct DiscoverItem: Hashable, Equatable {
    public let id: String
    public let apiUrl: String
    public let title: String
    public let subtitle: String?
    public let position: Int
    public let image: String?
    public let cover: String?
    public let icon: String?
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
}

extension DiscoverItem: JSONCodable {
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
            
        })
    }
}

public func ==(lhs: DiscoverItem, rhs: DiscoverItem) -> Bool {
    return lhs.id == rhs.id
}
