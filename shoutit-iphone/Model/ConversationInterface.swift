//
//  ConversationInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

public enum ConversationType : String {
    case Chat = "chat"
    case AboutShout = "about_shout"
    case PublicChat = "public_chat"
}

public protocol ConversationInterface {
    var id: String { get }
    var typeString: String { get }
    var unreadMessagesCount: Int { get }
    var display: ConversationDescription { get }
    var modifiedAt: Int? { get }
}

extension ConversationInterface {
    
    public func type() -> ConversationType {
        return ConversationType(rawValue: self.typeString)!
    }
    
    public func isPublicChat() -> Bool {
        return self.type() == .PublicChat
    }
    
    public func firstLineText() -> NSAttributedString? {
        guard let title = display.title else { return nil }
        return NSAttributedString(string: title)
    }
    
    public func secondLineText() -> NSAttributedString? {
        guard let subtitle = display.subtitle else { return nil }
        return NSAttributedString(string: subtitle)
    }
    
    public func thirdLineText() -> NSAttributedString? {
        guard let lastMessageSummary = display.lastMessageSummary else { return nil }
        return NSAttributedString(string: lastMessageSummary)
    }
    
    public func imageURL() -> NSURL? {
        if let path = display.image {
            return NSURL(string: path)
        }
        return nil
    }
    
    public func isRead() -> Bool {
        return self.unreadMessagesCount == 0
    }
    
    public func channelName() -> String {
        return "presence-v3-c-\(id)"
    }
}