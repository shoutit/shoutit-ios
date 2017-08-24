//
//  Display.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct DisplayRange {
    public let offset: Int
    public let length: Int
}

public struct Display {
    public let text: String
    public var ranges: [DisplayRange]?
    public let image: String?
}

extension DisplayRange: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        offset = try decoder.decode("offset")
        length = try decoder.decode("length")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(offset, key: "offset")
            try encoder.encode(length, key: "length")
        })
    }
}

extension Display: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        text = try decoder.decode("text")
        ranges = try decoder.decode("ranges")
        image = try decoder.decode("image")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(text, key: "text")
            try encoder.encode(ranges, key: "ranges")
            try encoder.encode(image, key: "image")
        })
    }
}


