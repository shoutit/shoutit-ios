//
//  Suggestions.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct Suggestions {
    public let users: [Profile]?
    public let pages: [Profile]?
    public let tags: [Tag]?
    
    public init(users: [Profile]?, pages: [Profile]?, tags: [Tag]?) {
        self.users = users
        self.pages = pages
        self.tags = tags
    }
}

extension Suggestions: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Suggestions> {
        return curry(Suggestions.init)
            <^> j <||? "users"
            <*> j <||? "pages"
            <*> j <||? "tags"
    }
}
