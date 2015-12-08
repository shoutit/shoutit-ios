//
//  SHMessage.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 02/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper

class SHMessage: Mappable {
    var user: SHUser?
    var conversation: SHConversations? //String()
    var createdAt: Int?
    var text = String()
    var messageId = String()
    var conversationId = String()
    var attachments = []
    var isRead = false
    var type = String()
    var status = String()
    var isFromShout: Bool?
    var localId = String()
    
    required init?(_ map: Map) {
        
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        user                 <- map["user"]
        conversation         <- map["conversation"]
        createdAt            <- map["created_at"]
        text                 <- map["text"]
        messageId            <- map["message_id"]
        conversationId       <- map["conversation_id"]
        attachments          <- map["attachments"]
        isRead               <- map["is_read"]
        type                 <- map["type"]
        status               <- map["status"]
        isFromShout          <- map["isFromShout"]
        localId              <- map["local_id"]
    }
    
}
