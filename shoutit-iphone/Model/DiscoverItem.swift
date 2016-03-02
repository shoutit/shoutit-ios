//
//  DiscoverItem.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct DiscoverItem: Decodable, Hashable, Equatable {
    let id: String
    let apiUrl: String
    let title: String
    let subtitle: String?
    let position: Int
    let image: String?
    let cover: String?
    let icon: String?
    
    static func decode(j: JSON) -> Decoded<DiscoverItem> {
        let f = curry(DiscoverItem.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "title"
        return f
            <*> j <|? "subtitle"
            <*> j <| "position"
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "icon"
    }
    
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
}

func ==(lhs: DiscoverItem, rhs: DiscoverItem) -> Bool {
    return lhs.id == rhs.id
}