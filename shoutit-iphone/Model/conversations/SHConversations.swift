//
//  SHConversations.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHConversations: Mappable {
    var id: String?
    var createdAt: Int?
    var modifiedAt: Int?
    var webUrl = String()
    var type = String()
    var messagesCount = String()
    var unreadMessagesCount = String()
    var admins = String()
    var users = [SHUser]()
    var lastMessage: SHMessage?
    var text = String()
    var attachments = []
    var about: SHShout?
    var messageUrl = String()
    var replyUrl = String()
    var isRead: Bool?
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        id                   <- map["id"]
        createdAt            <- map["created_at"]
        modifiedAt           <- map["modified_at"]
        webUrl               <- map["web_url"]
        type                 <- map["type"]
        messagesCount        <- map["messages_count"]
        unreadMessagesCount  <- map["unread_messages_count"]
        admins               <- map["admins"]
        users                <- map["users"]
        lastMessage          <- map["last_message"]
        text                 <- map["text"]
        attachments          <- map["attachments"]
        about                <- map["about"]
        messageUrl           <- map["message_url"]
        replyUrl             <- map["reply_url"]
        isRead               <- map["is_Read"]
        
    }
}
