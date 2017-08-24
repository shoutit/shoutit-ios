//
//  Message.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

public struct Notification: Hashable, Equatable {
    public let id: String
    public var read: Bool
    public let createdAt: Int
    
    public let type: String
    public let object:  AttachedObject?
    public let display: Display?
    
    public let webPath: String?
    public let appPath: String?
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    public mutating func markAsRead() {
        read = true
    }
    
    public func readCopy() -> Notification {
        return Notification(id: self.id, read: true, createdAt: self.createdAt, type: self.type, object: self.object, display: self.display, webPath: self.webPath, appPath:self.appPath)
    }
}

extension Notification: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        read = try decoder.decode("is_read")
        createdAt = try decoder.decode("created_at")
        type = try decoder.decode("type")
        self.object = try decoder.decode("attached_object")
        display = try decoder.decode("display")
        webPath = try decoder.decode("web_url")
        appPath = try decoder.decode("app_url")
        
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(read, key: "is_read")
            try encoder.encode(createdAt, key: "created_at")
            try encoder.encode(type, key: "type")
            try encoder.encode(object, key: "attached_object")
            try encoder.encode(display, key: "display")
            try encoder.encode(webPath, key: "web_url")
            try encoder.encode(appPath, key: "app_url")
        })
    }
}

extension Notification {
    public func attributedText() -> NSAttributedString? {
        
        if let display = self.display {
            let attributed = NSMutableAttributedString(string: display.text)
            
            guard let ranges = display.ranges else {
                return attributed
            }
            
            for range in ranges {
                attributed.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)], range: NSMakeRange(range.offset, range.length))
            }
            
            return attributed
        }

        return nil
    }
    
    public func imageURL() -> URL? {
        
        if let display = self.display, let path = display.image {
            return URL(string: path)
        }
        
        return nil
    }
    
}

public func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.id == rhs.id
}

