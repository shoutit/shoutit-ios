//
//  APIChatsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class APIChatsService {
    private static let conversationsURL = APIManager.baseURL + "/conversations"
    private static let messagesURL = APIManager.baseURL + "/conversations/*/messages"
    private static let replyURL = APIManager.baseURL + "/conversations/*/reply"
    private static let twilioURL = APIManager.baseURL + "/twilio/video_auth"
    
    // MARK: - Traditional

    static func requestConversations() -> Observable<[Conversation]> {
        return APIGenericService.requestWithMethod(.GET, url: conversationsURL, params: NopParams(), encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func getMessagesForConversation(conversation: Conversation, pageSize : Int = 50) -> Observable<[Message]> {
        let url = messagesURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, responseJsonPath: ["results"])
    }
    
    
    static func replyWithMessage(message: Message, onConversation conversation: Conversation) -> Observable<Message> {
        let url = replyURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.POST, url: url, params: MessageParams(message: message), encoding: .JSON)
    }
    
    static func twilioVideoAuth() -> Observable<TwilioAuth> {
        return APIGenericService.requestWithMethod(.GET, url: twilioURL, params: NopParams())
    }
    
    /*
    static func startConversationWithUsername(username: String) -> Observable<Conversation> {
        
    }
    */
}