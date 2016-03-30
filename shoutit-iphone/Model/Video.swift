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
import Ogra

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
            <*> j <| "thumbnail_url"
            <*> j <| "provider"
            <*> j <| "id_on_provider"
            <*> j <| "duration"
    }
}

extension Video: Encodable {
    func encode() -> JSON {
        return JSON.Object([
            "url"    : self.path.encode(),
            "thumbnail_url"  : self.thumbnailPath.encode(),
            "provider" : self.provider.encode(),
            "id_on_provider"    : self.idOnProvider.encode(),
            "duration"  : self.duration.encode()
            ])
    }
}