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
        
        return b
    }
    
    mutating func markAsRead() {
        read = true
    }
    
    func readCopy() -> Notification {
        return Notification(id: self.id, read: true, createdAt: self.createdAt, type: self.type, object: self.object)
    }
}

extension Notification {
    func attributedText() -> NSAttributedString? {
        if type == "new_listen" {
            return followAttributedText()
        }
        
        if type == "new_message" {
            return messageAttributedText()
        }
        
        return nil
    }
    
    func imageURL() -> NSURL? {
        if type == "new_listen" {
            return followImageURL()
        }
        if type == "new_message" {
            return messageImageURL()
        }
        
        return nil
    }
    
    func followAttributedText() -> NSAttributedString? {
        
        let base = NSLocalizedString("%%x Listened to you", comment: "")
        
        var name = NSLocalizedString("Someone", comment: "")
        
        if let profile = object?.profile {
           name = profile.name
        }
        
        let text = base.stringByReplacingOccurrencesOfString("%%x", withString: name)
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let range = (text as NSString).rangeOfString(name)
        
        attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], range: range)
        
        return attributedString
    }
    
    func messageAttributedText() -> NSAttributedString? {
        
        let base = NSLocalizedString("%%x: %%mm", comment: "")
        
        var name = NSLocalizedString("Someone", comment: "")
        
        if let profile = object?.message?.user {
            name = profile.name
        }
        
        var text = base.stringByReplacingOccurrencesOfString("%%x", withString: name)
        
        var msgText : String? = nil
        
        if let msg = object?.message, txt = msg.text {
            msgText = txt
        }
        
        text = text.stringByReplacingOccurrencesOfString("%%mm", withString: msgText ?? NSLocalizedString("Sends you message", comment: ""))
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let range = (text as NSString).rangeOfString(name)
        
        attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], range: range)
        
        return attributedString
    }
    
    func messageImageURL() -> NSURL? {
        
        if let message = object?.message, imagePath = message.user?.imagePath {
            return NSURL(string: imagePath)
        }
        
        return nil
    }
    
    func followImageURL() -> NSURL? {
        if let profile = object?.profile, imagePath = profile.imagePath {
            return NSURL(string: imagePath)
        }
        
        return nil
    }
}

func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.id == rhs.id
}

