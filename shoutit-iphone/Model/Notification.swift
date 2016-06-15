//
//  Message.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo


public struct Notification: Decodable, Hashable, Equatable {
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
    
    public static func decode(j: JSON) -> Decoded<Notification> {
        let a = curry(Notification.init)
            <^> j <| "id"
            <*> j <| "is_read"
            <*> j <| "created_at"
        let b = a
            <*> j <| "type"
            <*> j <|? "attached_object"
            <*> j <|? "display"
        let c = b
            <*> j <|? "web_url"
            <*> j <|? "app_url"
        
        return c
    }
    
    public mutating func markAsRead() {
        read = true
    }
    
    public func readCopy() -> Notification {
        return Notification(id: self.id, read: true, createdAt: self.createdAt, type: self.type, object: self.object, display: self.display, webPath: self.webPath, appPath:self.appPath)
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
                attributed.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], range: NSMakeRange(range.offset, range.length))
            }
            
            return attributed
        }

        return nil
    }
    
    public func imageURL() -> NSURL? {
        
        if let display = self.display, path = display.image {
            return NSURL(string: path)
        }
        
        return nil
    }
    
}

public func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.id == rhs.id
}

