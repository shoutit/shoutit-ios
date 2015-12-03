//
//  SHApiConversationService.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiConversationService: NSObject {
    private let CONVERSATIONS = SHApiManager.sharedInstance.BASE_URL + "/conversations"
    
    func loadConversationsForBeforeDate (beforeTimestamp: Int, cacheResponse: SHConversations -> Void, completionHandler: Response<SHConversations, NSError> -> Void) {
        var params = [String: AnyObject]()
        params["before"] = beforeTimestamp
        params["page_size"] = Constants.Common.SH_PAGE_SIZE
        SHApiManager.sharedInstance.get(CONVERSATIONS, params: params, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func deleteConversationID(conversationId: String, completionHandler: Response<String, NSError> -> Void) {
        let urlString = String(format: CONVERSATIONS + "/%@", arguments: [conversationId])
        let params = [String: AnyObject]()
        SHApiManager.sharedInstance.delete(urlString, params: params, completionHandler: completionHandler)
    }
    
}
