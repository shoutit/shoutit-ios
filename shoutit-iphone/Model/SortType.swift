//
//  SortType.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct SortType {
    public let type: String
    public let name: String
}

extension SortType: Decodable {
    
    public static func decode(j: JSON) -> Decoded<SortType> {
        return curry(SortType.init)
            <^> j <| "type"
            <*> j <| "name"
    }
}
