//
//  ListenSuccess.swift
//  shoutit
//
//  Created by Piotr Bernad on 01/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct ListenSuccess {
    public let message: String
    public let newListnersCount: Int
    
    public init(message: String, newListnersCount: Int = 0) {
        self.message = message
        self.newListnersCount = newListnersCount
    }
}

extension ListenSuccess: Decodable {
    public static func decode(j: JSON) -> Decoded<ListenSuccess> {
        return curry(ListenSuccess.init)
            <^> j <| "success"
            <*> j <| "new_listeners_count"
    }
}
