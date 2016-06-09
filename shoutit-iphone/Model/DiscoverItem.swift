//
//  DiscoverItem.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct DiscoverItem: Decodable, Hashable, Equatable {
    public let id: String
    public let apiUrl: String
    public let title: String
    public let subtitle: String?
    public let position: Int
    public let image: String?
    public let cover: String?
    public let icon: String?
    
    public static func decode(j: JSON) -> Decoded<DiscoverItem> {
        let f = curry(DiscoverItem.init)
            <^> j <| "id"
            <*> j <| "api_url"
            <*> j <| "title"
        let g = f
            <*> j <|? "subtitle"
            <*> j <| "position"
            <*> j <|? "image"
            <*> j <|? "cover"
            <*> j <|? "icon"
        return g
    }
    
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
}

public func ==(lhs: DiscoverItem, rhs: DiscoverItem) -> Bool {
    return lhs.id == rhs.id
}