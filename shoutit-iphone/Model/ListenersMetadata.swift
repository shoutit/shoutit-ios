//
//  ListenersMetadata.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry
import Ogra

public struct ListenersMetadata {
    public let pages: Int
    public let users: Int
    public let tags: Int
    
    public init(pages: Int, users: Int, tags: Int) {
        self.pages = pages
        self.users = users
        self.tags = tags
    }
}

extension ListenersMetadata: Decodable {
    
    public static func decode(j: JSON) -> Decoded<ListenersMetadata> {
        return curry(ListenersMetadata.init)
            <^> j <| "pages"
            <*> j <| "users"
            <*> j <| "tags"
    }
}

extension ListenersMetadata: Encodable {
    
    public func encode() -> JSON {
        return JSON.Object([
            "pages"    : self.pages.encode(),
            "users"  : self.users.encode(),
            "tags" : self.tags.encode(),
            ])
    }
}

extension ListenersMetadata: Equatable {}
public func ==(lhs: ListenersMetadata, rhs: ListenersMetadata) -> Bool {
    return lhs.pages == rhs.pages && lhs.users == rhs.users && lhs.tags == rhs.tags
}
