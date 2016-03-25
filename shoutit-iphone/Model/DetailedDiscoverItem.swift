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

struct DetailedDiscoverItem {
    let id: String
    let apiUrl: String
    let title: String
    let subtitle: String?
    let position: Int
    let image: String?
    let cover: String?
    let icon: String?
    let showChildren: Bool
    let children: [DiscoverItem]
    let showShouts: Bool
    let shoutsPath: String
    
    func simpleForm() -> DiscoverItem {
        return DiscoverItem(id: id, apiUrl: apiUrl, title: title, subtitle: subtitle, position: position, image: image, cover: cover, icon: icon)
    }
}

extension DetailedDiscoverItem: Decodable {
    
    static func decode(j: JSON) -> Decoded<DetailedDiscoverItem> {
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
            <*> j <| "shouts_url"
    }
}

extension DetailedDiscoverItem: Hashable, Equatable {
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
}

func ==(lhs: DetailedDiscoverItem, rhs: DetailedDiscoverItem) -> Bool {
    return lhs.id == rhs.id
}