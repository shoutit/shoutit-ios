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

public struct Video {
    public let path: String
    public let thumbnailPath: String
    public let provider: String
    public let idOnProvider: String
    public let duration: Int
    
    public init(path: String, thumbnailPath: String, provider: String, idOnProvider: String, duration: Int) {
        self.path = path
        self.thumbnailPath = thumbnailPath
        self.provider = provider
        self.idOnProvider = idOnProvider
        self.duration = duration
    }
}

extension Video: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Video> {
        return curry(Video.init)
            <^> j <| "url"
            <*> j <| "thumbnail_url"
            <*> j <| "provider"
            <*> j <| "id_on_provider"
            <*> j <| "duration"
    }
}

extension Video: Encodable {
    public func encode() -> JSON {
        return JSON.Object([
            "url"    : self.path.encode(),
            "thumbnail_url"  : self.thumbnailPath.encode(),
            "provider" : self.provider.encode(),
            "id_on_provider"    : self.idOnProvider.encode(),
            "duration"  : self.duration.encode()
            ])
    }
}