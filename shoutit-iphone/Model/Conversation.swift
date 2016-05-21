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

struct Conversation: ConversationInterface {
    
    let id: String
    let createdAt: Int?
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
    let blocked: [String]
    let admins: [String]
    let attachmentCount: AttachmentCount
    let creator: MiniProfile?
}

extension Conversation: Decodable {
    
    static func decode(j: JSON) -> Decoded<Conversation> {
        let a = curry(Conversation.init)
            <^> j <| "id"
            <*> j <|? "created_at"
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
        let f = d
            <*> j <|| "blocked"
            <*> j <|| "admins"
        let g = f
            <*> j <| "attachments_count"
            <*> j <|? "creator"
        return g
    }

}

extension Conversation: Equatable, Hashable {
    
    var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id && lhs.apiPath == rhs.apiPath
}

extension Conversation {
    
    func coParticipant() -> Profile? {
        var prof : Profile?
        self.users?.each({ (profile) -> () in
            if profile.value.id != Account.sharedInstance.user?.id {
                prof = profile.value
            }
        })
        
        return prof
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
