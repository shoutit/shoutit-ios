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
    case PublicChat = "public_chat"
}

struct Conversation: Decodable, Hashable, Equatable {
    
    let id: String
    let createdAt: Int
    let modifiedAt: Int?
    let apiPath: String?
    let webPath: String?
    let typeString: String
    let users: [Box<Profile>]?
    let lastMessage: Message?
    let unreadMessagesCount: Int
    let shout: Shout?
    let readby: [ReadBy]?
    let display: ConversationDescription
    let subject: String?
    let blocked: [String]
    let admins: [String]
    let icon: String?
    let attachmentCount: AttachmentCount
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
    
    static func decode(j: JSON) -> Decoded<Conversation> {
        let a = curry(Conversation.init)
            <^> j <| "id"
            <*> j <| "created_at"
            <*> j <|? "modified_at"
        let b = a
            <*> j <|? "api_url"
            <*> j <|? "web_url"
            <*> j <| "type"
        let c = b
            <*> j <||? "profiles"
            <*> j <|? "last_message"
            <*> j <| "unread_messages_count"
            <*> j <|? "about"
        let d = c
            <*> j <||? "read_by"
            <*> j <| "display"
            <*> j <|? "subject"
        let f = d
            <*> j <|| "blocked"
            <*> j <|| "admins"
            <*> j <|? "icon"
        let g = f
            <*> j <| "attachments_count"
        return g
    }
    
    func type() -> ConversationType {
        return ConversationType(rawValue: self.typeString)!
    }
    
    func copyWithLastMessage(message: Message?) -> Conversation {
        return Conversation(id: self.id,
                            createdAt: self.createdAt,
                            modifiedAt: self.modifiedAt,
                            apiPath: self.apiPath,
                            webPath: self.webPath,
                            typeString: self.typeString,
                            users: self.users,
                            lastMessage: message,
                            unreadMessagesCount: self.unreadMessagesCount + 1,
                            shout: self.shout,
                            readby: self.readby,
                            display: self.display,
                            subject: self.subject,
                            blocked: [],
                            admins: [],
                            icon: self.icon,
                            attachmentCount: self.attachmentCount)
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id && lhs.apiPath == rhs.apiPath
}

extension Conversation {
    
    func firstLineText() -> NSAttributedString? {
        guard let title = display.title else { return nil }
        return NSAttributedString(string: title)
    }
    
    func secondLineText() -> NSAttributedString? {
        guard let subtitle = display.subtitle else { return nil }
        return NSAttributedString(string: subtitle)
    }
    
    func coParticipant() -> Profile? {
        var prof : Profile?
        self.users?.each({ (profile) -> () in
            if profile.value.id != Account.sharedInstance.user?.id {
                prof = profile.value
            }
        })
        
        return prof
    }
    
    func thirdLineText() -> NSAttributedString? {
        guard let lastMessageSummary = display.lastMessageSummary else { return nil }
        return NSAttributedString(string: lastMessageSummary)
    }
    
    func lastMessageText() -> String {
        guard let msg = lastMessage else {
            return ""
        }
        
        if let text = msg.text {
            return text
        }
        
        guard let attachmentType = msg.attachment()?.type() else {
            return NSLocalizedString("Attachment", comment: "")
        }
        
        switch attachmentType {
        case .LocationAttachment: return NSLocalizedString("Location", comment: "")
        case .ImageAttachment: return NSLocalizedString("Image", comment: "")
        case .VideoAttachment: return NSLocalizedString("Video", comment: "")
        case .ShoutAttachment: return NSLocalizedString("Shout", comment: "")
        case .ProfileAttachment: return NSLocalizedString("Profile", comment: "")
        }
    }
    
    func imageURL() -> NSURL? {
        var url : NSURL?
        
        if let path = self.display.image {
            url = NSURL(string: path)
        }
        
        return url
    }
    
    func isRead() -> Bool {
        return self.unreadMessagesCount == 0
    }
}

// Public Chats Helpers

extension Conversation {
    func isAdmin(profileId: String?) -> Bool {
        guard let profileId = profileId else {
            return false
        }
        return self.admins.contains(profileId)
    }
}

// Pusher Extensions
extension Conversation {
    func channelName() -> String {
        return "presence-v3-c-\(self.id)"
    }
}