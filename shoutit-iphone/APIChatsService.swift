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
    private static let shoutsURL = APIManager.baseURL + "/conversations/*/shouts"
    private static let mediaURL = APIManager.baseURL + "/conversations/*/media"
    private static let readMessageURL = APIManager.baseURL + "/messages/*/read"
    private static let replyURL = APIManager.baseURL + "/conversations/*/reply"
    private static let twilioURL = APIManager.baseURL + "/twilio/video_auth"
    private static let twilioIdentityURL = APIManager.baseURL + "/twilio/video_identity"
    private static let twilioVideCallURL = APIManager.baseURL + "/twilio/video_call"
    private static let replyShoutsURL = APIManager.baseURL + "/shouts/*/reply"
    private static let conversationURL = APIManager.baseURL + "/conversations/*"
    private static let conversationReadURL = APIManager.baseURL + "/conversations/*/read"
    private static let conversationAddProfileURL = APIManager.baseURL + "/conversations/*/add_profile"
    private static let conversationBlockedProfilesURL = APIManager.baseURL + "/conversations/*/blocked"
    
    private static let conversationUnblockProfileURL = APIManager.baseURL + "/conversations/*/unblock_profile"
    private static let conversationBlockProfileURL = APIManager.baseURL + "/conversations/*/block_profile"
    private static let conversationPromoteAdminProfileURL = APIManager.baseURL + "/conversations/*/promote_admin"

    static func requestConversationsWithParams(params: ConversationsListParams, explicitURL: String? = nil) -> Observable<PagedResults<Conversation>> {
        let url = explicitURL ?? conversationsURL
        let params: ConversationsListParams? = explicitURL == nil ? params : nil
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func getMessagesForConversation(conversation: Conversation) -> Observable<PagedResults<Message>> {
        let url = messagesURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func getShoutsForConversationWithId(id: String, params: PageParams) -> Observable<PagedResults<Shout>> {
        let url = shoutsURL.stringByReplacingOccurrencesOfString("*", withString: id)
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func getAttachmentsForConversationWithId(id: String, params: PageParams) -> Observable<PagedResults<MessageAttachment>> {
        let url = mediaURL.stringByReplacingOccurrencesOfString("*", withString: id)
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func moreMessagesForConversation(conversation: Conversation, nextPageParams: String?) -> Observable<PagedResults<Message>> {
        let url = messagesURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id) + (nextPageParams ?? "")
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL, responseJsonPath: nil)
    }
    
    static func markConversationAsRead(conversation: Conversation) -> Observable<Void> {
        let url = conversationReadURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: NopParams(), encoding: .JSON)
    }
    
    static func markMessageAsRead(message: Message) -> Observable<Void> {
        let url = readMessageURL.stringByReplacingOccurrencesOfString("*", withString: message.id)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: NopParams(), encoding: .JSON)
    }
    
    static func replyWithMessage(message: Message, onConversation conversation: Conversation) -> Observable<Message> {
        let url = replyURL.stringByReplacingOccurrencesOfString("*", withString: conversation.id)
        return APIGenericService.requestWithMethod(.POST, url: url, params: MessageParams(message: message), encoding: .JSON)
    }
    
    static func twilioVideoAuth() -> Observable<TwilioAuth> {
        return APIGenericService.requestWithMethod(.POST, url: twilioURL, params: NopParams())
    }
    
    static func twilioVideoCallWithParams(params: VideoCallParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.POST, url: twilioVideCallURL, params: params, encoding: .JSON)
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
    
    static func updateConversationWithId(conversationId: String, params: ConversationUpdateParams) -> Observable<Conversation> {
        let url = conversationURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON)
    }
    
    static func addMemberToConversationWithId(conversationId: String, profile: Profile) -> Observable<Void> {
        let url = conversationAddProfileURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: .JSON)
    }
    
    static func blockProfileInConversationWithId(conversationId: String, profile: Profile) -> Observable<Void> {
        let url = conversationBlockProfileURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: .JSON)
    }
    
    static func unblockProfileInConversationWithId(conversationId: String, profile: Profile) -> Observable<Void> {
        let url = conversationUnblockProfileURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: .JSON)
    }
    
    static func promoteToAdminProfileInConversationWithId(conversationId: String, profile: Profile) -> Observable<Void> {
        let url = conversationPromoteAdminProfileURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: .JSON)
    }
    
    static func getBlockedProfilesForConversation(conversationId: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = conversationBlockedProfilesURL.stringByReplacingOccurrencesOfString("*", withString: conversationId)
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
}