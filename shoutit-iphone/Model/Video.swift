//
//  Video.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Video {
    let path: String
    let thumbnailPath: String
    let provider: String
    let idOnProvider: String
    let duration: Int
}

extension Video: Decodable {
    
    static func decode(j: JSON) -> Decoded<Video> {
        return curry(Video.init)
            <^> j <| "url"
            <*> j <| "thumbnail"
            <*> j <| "provider"
            <*> j <| "id_on_provider"
            <*> j <| "duration"
    }
}
