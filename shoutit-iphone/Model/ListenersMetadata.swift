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

struct ListenersMetadata {
    let pages: Int
    let users: Int
    let tags: Int
}

extension ListenersMetadata: Decodable {
    
    static func decode(j: JSON) -> Decoded<ListenersMetadata> {
        return curry(ListenersMetadata.init)
            <^> j <| "pages"
            <*> j <| "users"
            <*> j <| "tags"
    }
}

extension ListenersMetadata: Encodable {
    
    func encode() -> JSON {
        return JSON.Object([
            "pages"    : self.pages.encode(),
            "users"  : self.users.encode(),
            "tags" : self.tags.encode(),
            ])
    }
}
