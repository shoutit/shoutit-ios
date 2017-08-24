//
//  ConversationDescription.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import JSONCodable

public struct ConversationDescription {
    
    public let title: String?
    public let subtitle: String?
    public let image: String?
    public let lastMessageSummary: String?
    
    public static var nilDescription: ConversationDescription {
        return ConversationDescription(title: nil, subtitle: nil, image: nil, lastMessageSummary: nil)
    }
}

extension ConversationDescription: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        title = try decoder.decode("title")
        subtitle = try decoder.decode("sub_title")
        image = try decoder.decode("image")
        lastMessageSummary = try decoder.decode("last_message_summary")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(title, key: "title")
            try encoder.encode(subtitle, key: "sub_title")
            try encoder.encode(image, key: "image")
        })
    }
}
