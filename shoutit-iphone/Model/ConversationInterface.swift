//
//  ConversationInterface.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 20.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum ConversationType : String {
    case Chat = "chat"
    case AboutShout = "about_shout"
    case PublicChat = "public_chat"
}

protocol ConversationInterface {
    var id: String { get }
    var typeString: String { get }
    var unreadMessagesCount: Int { get }
    var display: ConversationDescription { get }
    var modifiedAt: Int? { get }
}

extension ConversationInterface {
    
    func type() -> ConversationType {
        return ConversationType(rawValue: self.typeString)!
    }
    
    func firstLineText() -> NSAttributedString? {
        guard let title = display.title else { return nil }
        return NSAttributedString(string: title)
    }
    
    func secondLineText() -> NSAttributedString? {
        guard let subtitle = display.subtitle else { return nil }
        return NSAttributedString(string: subtitle)
    }
    
    func thirdLineText() -> NSAttributedString? {
        guard let lastMessageSummary = display.lastMessageSummary else { return nil }
        return NSAttributedString(string: lastMessageSummary)
    }
    
    func imageURL() -> NSURL? {
        if let path = display.image {
            return NSURL(string: path)
        }
        return nil
    }
    
    func isRead() -> Bool {
        return self.unreadMessagesCount == 0
    }
    
    func channelName() -> String {
        return "presence-v3-c-\(id)"
    }
}