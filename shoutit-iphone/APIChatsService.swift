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

final class APIChatsService {
    private static let conversationsURL = APIManager.baseURL + "/conversations"
    private static let conversationWithUserURL = APIManager.baseURL + "/profiles/*/chat"
    private static let messagesURL = APIManager.baseURL + "/conversations/*/messages"
    private static let replyURL = APIManager.baseURL + "/conversations/*/reply"
    private static let twilioURL = APIManager.baseURL + "/twilio/video_auth"
    private static let twilioIdentityURL = APIManager.baseURL + "/twilio/video_identity"
    private static let twilioMissedCallURL = APIManager.baseURL + "/twilio/video_call"
    private static let replyShoutsURL = APIManager.baseURL + "/shouts/*/reply"
    private static let conversationURL = APIManager.baseURL + "/conversations/*"
    private static let conversationReadURL = APIManager.baseURL + "/conversations/*/read"
    // MARK: - Traditional

    static func requestConversations() -> Observable<PagedResponse<Conversation>> {
        return APIGenericService.requestWithMethod(.GET, url: conversationsURL, params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func requestMoreConversations(nextPageParams: String?) -> Observable<PagedResponse<Conversation>> {
        return APIGenericService.requestWithMethod(.GET, url: conversationsURL + (nextPageParams ?? ""), params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func getMessagesForConversation(conversation: Conversation, pageSize : Int = 50) -> Observable<PagedResponse<Message>> {
        let url = messagesURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func moreMessagesForConversation(conversation: Conversation, nextPageParams: String?) -> Observable<PagedResponse<Message>> {
        let url = messagesURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id) + (nextPageParams ?? "")
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func markConversationAsRead(conversation: Conversation) -> Observable<Void> {
        let url = conversationReadURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: NopParams(), encoding: .JSON)
    }
    
    static func replyWithMessage(message: Message, onConversation conversation: Conversation) -> Observable<Message> {
        let url = replyURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.POST, url: url, params: MessageParams(message: message), encoding: .JSON)
    }
    
    static func twilioVideoAuth() -> Observable<TwilioAuth> {
        return APIGenericService.requestWithMethod(.POST, url: twilioURL, params: NopParams())
    }
    
    static func twilioMissedCallWithParams(params: MissedCallParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: twilioMissedCallURL, params: params, encoding: .JSON)
    }
    
    static func twilioVideoIdentity(username: String) -> Observable<TwilioIdentity> {
        return APIGenericService.requestWithMethod(.GET, url: twilioIdentityURL + "?profile=\(username)", params: NopParams())
    }
        
    static func startConversationWithUsername(username: String, message: Message) -> Observable<Message> {
        let url = conversationWithUserURL.stringByReplacingOccurrencesOfString("*", withString: username)
        return APIGenericService.requestWithMethod(.POST, url: url, params: MessageParams(message: message), encoding: .JSON)
    }
    
    static func startConversationAboutShout(shout: Shout, message: Message) -> Observable<Message> {
        let url = replyShoutsURL.stringByReplacingOccurrencesOfString("*", withString: shout.id)
        return APIGenericService.requestWithMethod(.POST, url: url, params: MessageParams(message: message), encoding: .JSON)
    }
    
    static func deleteConversation(conversation: Conversation) -> Observable<Void> {
        let url = conversationURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.basicRequestWithMethod(.DELETE, url: url, params: NopParams(), encoding: .JSON)

    }
    
    static func conversationWithId(conversationId: String) -> Observable<Conversation> {
        let url = conversationURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .JSON)
        
    }
}