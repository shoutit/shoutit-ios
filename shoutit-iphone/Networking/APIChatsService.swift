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
import ShoutitKit

final class APIChatsService {
    fileprivate static let conversationsURL = APIManager.baseURL + "/conversations"
    fileprivate static let conversationWithUserURL = APIManager.baseURL + "/profiles/*/chat"
    fileprivate static let messagesURL = APIManager.baseURL + "/conversations/*/messages"
    fileprivate static let shoutsURL = APIManager.baseURL + "/conversations/*/shouts"
    fileprivate static let mediaURL = APIManager.baseURL + "/conversations/*/media"
    fileprivate static let readMessageURL = APIManager.baseURL + "/messages/*/read"
    fileprivate static let replyURL = APIManager.baseURL + "/conversations/*/reply"
    fileprivate static let twilioURL = APIManager.baseURL + "/twilio/video_auth"
    fileprivate static let twilioIdentityURL = APIManager.baseURL + "/twilio/video_identity"
    fileprivate static let twilioVideCallURL = APIManager.baseURL + "/twilio/video_call"
    fileprivate static let replyShoutsURL = APIManager.baseURL + "/shouts/*/reply"
    fileprivate static let conversationURL = APIManager.baseURL + "/conversations/*"
    fileprivate static let conversationReadURL = APIManager.baseURL + "/conversations/*/read"
    fileprivate static let conversationAddProfileURL = APIManager.baseURL + "/conversations/*/add_profile"
    fileprivate static let conversationRemoveProfileURL = APIManager.baseURL + "/conversations/*/remove_profile"
    fileprivate static let conversationBlockedProfilesURL = APIManager.baseURL + "/conversations/*/blocked"
    
    fileprivate static let conversationUnblockProfileURL = APIManager.baseURL + "/conversations/*/unblock_profile"
    fileprivate static let conversationBlockProfileURL = APIManager.baseURL + "/conversations/*/block_profile"
    fileprivate static let conversationPromoteAdminProfileURL = APIManager.baseURL + "/conversations/*/promote_admin"

    static func requestConversationsWithParams(_ params: ConversationsListParams, explicitURL: String? = nil) -> Observable<PagedResults<MiniConversation>> {
        let url = explicitURL ?? conversationsURL
        let params: ConversationsListParams? = explicitURL == nil ? params : nil
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default)
    }
    
    static func getMessagesForConversationWithId(_ conversationId: String) -> Observable<PagedResults<Message>> {
        let url = messagesURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, responseJsonPath: nil)
    }
    
    static func getShoutsForConversationWithId(_ id: String, params: PageParams) -> Observable<PagedResults<Shout>> {
        let url = shoutsURL.replacingOccurrences(of: "*", with: id)
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default)
    }
    
    static func getAttachmentsForConversationWithId(_ id: String, params: PageParams) -> Observable<PagedResults<MessageAttachment>> {
        let url = mediaURL.replacingOccurrences(of: "*", with: id)
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default)
    }
    
    static func moreMessagesForConversationWithId(_ conversationId: String, nextPageParams: String?) -> Observable<PagedResults<Message>> {
        let url = messagesURL.replacingOccurrences(of: "*", with: conversationId) + (nextPageParams ?? "")
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: URLEncoding.default, responseJsonPath: nil)
    }
    
    static func markConversationAsRead(_ conversation: Conversation) -> Observable<Void> {
        let url = conversationReadURL.replacingOccurrences(of: "*", with: conversation.id)
        return APIGenericService.basicRequestWithMethod(.post, url: url, params: NopParams(), encoding: JSONEncoding.default)
    }
    
    static func markMessageAsRead(_ message: Message) -> Observable<Void> {
        let url = readMessageURL.replacingOccurrences(of: "*", with: message.id)
        return APIGenericService.basicRequestWithMethod(.post, url: url, params: NopParams(), encoding: JSONEncoding.default)
    }
    
    static func replyWithMessage(_ message: Message, onConversationWithId id: String) -> Observable<Message> {
        let url = replyURL.replacingOccurrences(of: "*", with: id)
        return APIGenericService.requestWithMethod(.post, url: url, params: MessageParams(message: message), encoding: JSONEncoding.default)
    }
    
    static func twilioVideoAuth() -> Observable<TwilioAuth> {
        return APIGenericService.requestWithMethod(.post, url: twilioURL, params: NopParams())
    }
    
    static func twilioVideoCallWithParams(_ params: VideoCallParams) -> Observable<Void> {
        return APIGenericService.basicRequestWithMethod(.post, url: twilioVideCallURL, params: params, encoding: JSONEncoding.default)
    }
    
    static func twilioVideoIdentity(_ username: String) -> Observable<TwilioIdentity> {
        return APIGenericService.requestWithMethod(.get, url: twilioIdentityURL + "?profile=\(username)", params: NopParams())
    }
        
    static func startConversationWithUsername(_ username: String, message: Message) -> Observable<Message> {
        let url = conversationWithUserURL.replacingOccurrences(of: "*", with: username)
        return APIGenericService.requestWithMethod(.post, url: url, params: MessageParams(message: message), encoding: JSONEncoding.default)
    }
    
    static func startConversationAboutShout(_ shout: Shout, message: Message) -> Observable<Message> {
        let url = replyShoutsURL.replacingOccurrences(of: "*", with: shout.id)
        return APIGenericService.requestWithMethod(.post, url: url, params: MessageParams(message: message), encoding: JSONEncoding.default)
    }
    
    static func deleteConversationWithId(_ conversationId: String) -> Observable<Void> {
        let url = conversationURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.basicRequestWithMethod(.delete, url: url, params: NopParams(), encoding: JSONEncoding.default)
    }
    
    static func conversationWithId(_ conversationId: String) -> Observable<Conversation> {
        let url = conversationURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.get, url: url, params: NopParams(), encoding: JSONEncoding.default)
    }
    
    static func updateConversationWithId(_ conversationId: String, params: ConversationUpdateParams) -> Observable<Conversation> {
        let url = conversationURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.patch, url: url, params: params, encoding: JSONEncoding.default)
    }
    
    static func addMemberToConversationWithId(_ conversationId: String, profile: Profile) -> Observable<Success> {
        let url = conversationAddProfileURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.post, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: JSONEncoding.default)
    }
    
    static func removeMemberFromConversationWithId(_ conversationId: String, profile: Profile) -> Observable<Success> {
        let url = conversationRemoveProfileURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.post, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: JSONEncoding.default)
    }
    
    static func blockProfileInConversationWithId(_ conversationId: String, profile: Profile) -> Observable<Success> {
        let url = conversationBlockProfileURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.post, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: JSONEncoding.default)
    }
    
    static func unblockProfileInConversationWithId(_ conversationId: String, profile: Profile) -> Observable<Success> {
        let url = conversationUnblockProfileURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.post, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: JSONEncoding.default)
    }
    
    static func promoteToAdminProfileInConversationWithId(_ conversationId: String, profile: Profile) -> Observable<Success> {
        let url = conversationPromoteAdminProfileURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.post, url: url, params: ConversationMemberParams(profileId: profile.id), encoding: JSONEncoding.default)
    }
    
    static func getBlockedProfilesForConversation(_ conversationId: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = conversationBlockedProfilesURL.replacingOccurrences(of: "*", with: conversationId)
        return APIGenericService.requestWithMethod(.get, url: url, params: params, encoding: URLEncoding.default, headers: ["Accept": "application/json"])
    }
}
