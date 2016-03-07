//
//  Suggestions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Suggestions {
    let users: [Profile]?
    let pages: [Profile]?
    let tags: [Tag]?
}

extension Suggestions: Decodable {
    
    static func decode(j: JSON) -> Decoded<Suggestions> {
        return curry(Suggestions.init)
            <^> j <||? "users"
            <*> j <||? "pages"
            <*> j <||? "tags"
    }
}
