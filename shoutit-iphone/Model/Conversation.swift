//
//  Conversation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo
import Curry

enum ConversationType : String {
    case Chat = "chat"
    case AboutShout = "about_shout"
}

struct Conversation: Decodable, Hashable, Equatable {
    let id: String
    let createdAt: Int
    let modifiedAt: Int
    let apiPath: String?
    let webPath: String?
    let typeString: String
    let users: [Profile]?
    let lastMessage: Message?
    let shout: Shout?
    let readby: [ReadBy]?
 
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Conversation> {
        let a = curry(Conversation.init)
            <^> j <| "id"
            <*> j <| "created_at"
            <*> j <| "modified_at"
        
        let b = a
            <*> j <|? "api_url"
            <*> j <|? "web_url"
            <*> j <| "type"
        
        let c = b
            <*> j <||? "users"
            <*> j <|? "last_message"
            <*> j <|? "about"
            
        let d = c
            <*> j <||? "read_by"
        
        return d
    }
    
    func type() -> ConversationType {
        return ConversationType(rawValue: self.typeString)!
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id
}

extension Conversation {
    func firstLineText() -> NSAttributedString? {
        if self.type() == .Chat {
            return NSAttributedString(string: participantNames())
        }
        
        return shoutTitle()
    }
    
    func shoutTitle() -> NSAttributedString? {
        guard let shout = self.shout else {
            return NSAttributedString(string: "Shout discussion")
        }
        
        let attributedString = NSMutableAttributedString(string: shout.title, attributes: [NSForegroundColorAttributeName: UIColor(red: 64.0/255.0, green: 196.0/255.0, blue: 255.0/255.0, alpha: 1.0)])
        
        return attributedString
    }
    
    func participantNames() -> String {
        var names : [String] = []
        
        self.users?.each({ (profile) -> () in
            if profile.id != Account.sharedInstance.user?.id {
                names.append(profile.name)
            }
        })
        
        if self.users?.count > 2 {
            names.insert(NSLocalizedString("You", comment: ""), atIndex: 0)
        }
        
        return names.joinWithSeparator(", ")
    }
    
    func secondLineText() -> NSAttributedString? {
        if self.type() == .Chat {
            return NSAttributedString(string: lastMessageText())
        }
        
        return NSAttributedString(string: participantNames())
    }
    
    func thirdLineText() -> NSAttributedString? {
        return NSAttributedString(string: lastMessageText())
    }
    
    func lastMessageText() -> String {
        guard let msg = lastMessage else {
            return ""
        }
        
        if let text = msg.text {
            return text
        }
        
        return NSLocalizedString("Attachment", comment: "")
    }
    
    func imageURL() -> NSURL? {
        var url : NSURL?
        
        self.users?.each({ (profile) -> () in
            if profile.id != Account.sharedInstance.user?.id {
                if let path = profile.imagePath {
                    url = NSURL(string: path)
                    return
                }
            }
        })
        
        return url
    }
    
    func isRead() -> Bool {
        
        if let readby = self.readby {
            for read in readby {
                if read.profileId == Account.sharedInstance.user?.id {
                    return true
                }
            }
        }
        
        return false
    }
}