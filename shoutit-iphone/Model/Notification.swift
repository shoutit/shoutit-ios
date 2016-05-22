//
//  Message.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Notification: Decodable, Hashable, Equatable {
    let id: String
    var read: Bool
    let createdAt: Int
    
    let type: String
    let object:  AttachedObject?
    let display: Display?
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Notification> {
        let a = curry(Notification.init)
            <^> j <| "id"
            <*> j <| "is_read"
            <*> j <| "created_at"
        let b = a
            <*> j <| "type"
            <*> j <|? "attached_object"
            <*> j <|? "display"
        
        return b
    }
    
    mutating func markAsRead() {
        read = true
    }
    
    func readCopy() -> Notification {
        return Notification(id: self.id, read: true, createdAt: self.createdAt, type: self.type, object: self.object, display: nil)
    }
}

extension Notification {
    func attributedText() -> NSAttributedString? {
        
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
    
    func imageURL() -> NSURL? {
        
        if let display = self.display, path = display.image {
            return NSURL(string: path)
        }
        
        return nil
    }
    
}

func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.id == rhs.id
}

