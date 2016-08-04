//
//  Conversation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Argo

public struct Conversation: ConversationInterface {
    
    public let id: String
    public let createdAt: Int?
    public let modifiedAt: Int?
    public let apiPath: String?
    public let webPath: String?
    public let typeString: String
    public let users: [Box<Profile>]?
    public let lastMessage: Message?
    public let unreadMessagesCount: Int
    public let shout: Shout?
    public let readby: [ReadBy]?
    public let display: ConversationDescription
    public let blocked: [String]?
    public let admins: [String]
    public let attachmentCount: AttachmentCount
    public let creator: MiniProfile?
}

extension Conversation: Decodable {
    
    public static func decode(j: JSON) -> Decoded<Conversation> {
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
            <*> j <||? "blocked"
            <*> j <|| "admins"
        let g = f
            <*> j <| "attachments_count"
            <*> j <|? "creator"
        return g
    }

}

extension Conversation: Equatable, Hashable {
    
    public var hashValue: Int {
        get {
            return self.id.hashValue
        }
    }
}

public func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id && lhs.apiPath == rhs.apiPath
}

extension Conversation {
    
    public func coParticipant(currentUserId: String?) -> Profile? {
        var prof : Profile?
        self.users?.each({ (profile) -> () in
            if profile.value.id != currentUserId {
                prof = profile.value
            }
        })
        
        return prof
    }
    
    public func lastMessageText() -> String {
        guard let msg = lastMessage else {
            return ""
        }
        
        if let text = msg.text {
            return text
        }
        
        guard let attachmentType = msg.attachment()?.type() else {
            return NSLocalizedString("Attachment", comment: "Last Message Text")
        }
        
        switch attachmentType {
        case .LocationAttachment: return NSLocalizedString("Location", comment: "Last Message Text")
        case .ImageAttachment: return NSLocalizedString("Image", comment: "Last Message Text")
        case .VideoAttachment: return NSLocalizedString("Video", comment: "Last Message Text")
        case .ShoutAttachment: return NSLocalizedString("Shout", comment: "Last Message Text")
        case .ProfileAttachment: return NSLocalizedString("Profile", comment: "Last Message Text")
        }
    }
}

extension Conversation : Reportable {
    public func attachedObjectJSON() -> JSON {
        return ["conversation" : ["id" : self.id.encode()].encode()].encode()
    }
    
    public func reportTitle() -> String {
        return NSLocalizedString("Report Chat", comment: "Report Button Title")
    }
}

// Public Chats Helpers
extension Conversation {
    public func isAdmin(profileId: String?) -> Bool {
        guard let profileId = profileId else {
            return false
        }
        return self.admins.contains(profileId)
    }
}
