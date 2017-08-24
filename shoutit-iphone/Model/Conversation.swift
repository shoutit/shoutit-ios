//
//  Conversation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import JSONCodable

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

extension Conversation: JSONCodable {
    public init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        id = try decoder.decode("id")
        createdAt = try decoder.decode("created_at")
        modifiedAt = try decoder.decode("modified_at")
        apiPath = try decoder.decode("api_url")
        webPath = try decoder.decode("web_url")
        typeString = try decoder.decode("type")
        users = try decoder.decode("profiles")
        lastMessage = try decoder.decode("last_message")
        unreadMessagesCount = try decoder.decode("unread_messages_count")
        shout = try decoder.decode("about")
        readby = try decoder.decode("read_by")
        display = try decoder.decode("display")
        blocked = try decoder.decode("blocked")
        admins = try decoder.decode("admins")
        attachmentCount = try decoder.decode("attachments_count")
        creator = try decoder.decode("creator")
    }
    
    public func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(id, key: "id")
            try encoder.encode(createdAt, key: "created_at")
            try encoder.encode(modifiedAt, key: "modified_at")
            try encoder.encode(apiPath, key: "api_url")
            try encoder.encode(webPath, key: "web_url")
            try encoder.encode(typeString, key: "type")
            try encoder.encode(users, key: "profiles")
            try encoder.encode(lastMessage, key: "last_message")
            try encoder.encode(unreadMessagesCount, key: "unread_messages_count")
            try encoder.encode(shout, key: "about")
            try encoder.encode(readby, key: "read_by")
            try encoder.encode(display, key: "display")
            try encoder.encode(blocked, key: "blocked")
            try encoder.encode(admins, key: "name")
            try encoder.encode(attachmentCount, key: "attachments_count")
            try encoder.encode(creator, key: "creator")
        })
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
    
    public func coParticipant(_ currentUserId: String?) -> Profile? {
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
        case .locationAttachment: return NSLocalizedString("Location", comment: "Last Message Text")
        case .imageAttachment: return NSLocalizedString("Image", comment: "Last Message Text")
        case .videoAttachment: return NSLocalizedString("Video", comment: "Last Message Text")
        case .shoutAttachment: return NSLocalizedString("Shout", comment: "Last Message Text")
        case .profileAttachment: return NSLocalizedString("Profile", comment: "Last Message Text")
        }
    }
}

extension Conversation : Reportable {
    public var reportTypeKey: String {
        return "conversation"
    }
    
    public func reportTitle() -> String {
        return NSLocalizedString("Report Chat", comment: "Report Button Title")
    }
}

// Public Chats Helpers
extension Conversation {
    public func isAdmin(_ profileId: String?) -> Bool {
        guard let profileId = profileId else {
            return false
        }
        return self.admins.contains(profileId)
    }
}
