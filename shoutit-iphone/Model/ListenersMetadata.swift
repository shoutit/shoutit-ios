//
//  ListenersMetadata.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Genome

struct ListenersMetadata {
    
    private(set) var pages: Int = 0
    private(set) var users: Int = 0
    private(set) var tags: Int = 0
}

extension ListenersMetadata: BasicMappable {
    
    mutating func sequence(map: Map) throws {
        try pages                   <~ map["pages"]
        try users                   <~ map["users"]
        try tags                    <~ map["tags"]
    }
}
