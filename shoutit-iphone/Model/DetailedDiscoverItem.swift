//
//  DetailedDiscoverItem.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

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

extension DetailedDiscoverItem: Decodable {
    
    public static func decode(j: JSON) -> Decoded<DetailedDiscoverItem> {
        let f = curry(DetailedDiscoverItem.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "title"
        let g = f
            <*> j <|? "subtitle"
            <*> j <| "position"
            <*> j <|? "image"
            <*> j <|? "cover"
        let h = g
            <*> j <|? "icon"
            <*> j <| "show_children"
            <*> j <|| "children"
        return h
            <*> j <| "show_shouts"
            <*> j <|? "shouts_url"
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