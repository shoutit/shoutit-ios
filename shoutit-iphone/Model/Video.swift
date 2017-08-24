//
//  Video.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Video: Hashable, Equatable {
    public let path: String
    public let thumbnailPath: String
    public let provider: String
    public let idOnProvider: String
    public let duration: Int
    
    public var hashValue: Int {return path.hashValue}
    
    public init(path: String, thumbnailPath: String, provider: String, idOnProvider: String, duration: Int) {
        self.path = path
        self.thumbnailPath = thumbnailPath
        self.provider = provider
        self.idOnProvider = idOnProvider
        self.duration = duration
    }
}

extension Video: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        path = try decoder.decode("url")
        thumbnailPath = try decoder.decode("thumbnail_url")
        provider = try decoder.decode("provider")
        idOnProvider = try decoder.decode("idOnProvider")
        duration = try decoder.decode("duration")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(path, key: "url")
            try encoder.encode(thumbnailPath, key: "thumbnail_url")
            try encoder.encode(provider, key: "provider")
            try encoder.encode(idOnProvider, key: "idOnProvider")
            try encoder.encode(duration, key: "duration")
            
        })
    }
}

public func ==(lhs: Video, rhs: Video) -> Bool {
    return lhs.path == rhs.path
}
