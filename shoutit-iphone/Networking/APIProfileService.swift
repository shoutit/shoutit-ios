//
//  APIProfileService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import ShoutitKit

final class APIProfileService {
    
    static func searchProfileWithParams(_ params: SearchParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url)
    }
    
    static func listen(_ listen: Bool, toProfileWithUsername username: String) -> Observable<ListenSuccess> {
        let url = APIManager.baseURL + "/profiles/\(username)/listen"
        let method: Alamofire.Method = listen ? .POST : .DELETE
        return APIGenericService.requestWithMethod(method, url: url, params: NopParams(), encoding: .url, headers: nil)
    }
    
    static func retrieveProfileWithUsername(_ username: String, additionalPageIdHeader: String? = nil) -> Observable<DetailedUserProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        let headers: [String : String]? = additionalPageIdHeader != nil ? ["Authorization-Page-Id" : additionalPageIdHeader!] : nil
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .url, headers: headers)
    }
    
    static func retrievePageProfileWithUsername(_ username: String, additionalPageIdHeader: String? = nil) -> Observable<DetailedPageProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        let headers: [String : String]? = additionalPageIdHeader != nil ? ["Authorization-Page-Id" : additionalPageIdHeader!] : nil
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .url, headers: headers)
    }
    
    static func retrieveProfileWithTwilioUsername(_ twilio: String) -> Observable<Profile> {
        let url = APIManager.baseURL + "/twilio/profile?identity=\(twilio)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .url)
    }
    
    static func editUserWithUsername(_ username: String, withParams params: EditProfileParams) -> Observable<DetailedUserProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .json)
    }
    
    
    static func editPageWithUsername(_ username: String, withParams params: EditPageParams) -> Observable<DetailedPageProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .json)
    }
    
    static func nullifyPushTokens() -> Observable<Void> {
        let url = APIManager.baseURL + "/profiles/me"
        let tokens = PushTokens(apns: nil, gcm: nil)
        let params = APNParams(tokens: tokens)
        return APIGenericService.basicRequestWithMethod(.PATCH, url: url, params: params, encoding: .json)
    }
    
    static func updateAPNsWithUsername<T: Decodable>(_ username: String, withParams params: APNParams) -> Observable<T> where T == T.DecodedType, T: User {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .json)
    }
    
    static func editEmailForUserWithUsername(_ username: String, withEmailParams params: EmailParams) -> Observable<DetailedUserProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .json)
    }
    
    static func homeShoutsWithParams(_ params: FilteredShoutsParams) -> Observable<PagedResults<Shout>> {
        let url = APIManager.baseURL + "/profiles/me/home"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func getListeningProfilesForUsername(_ username: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/\(username)/listening"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func getListenersProfilesForUsername(_ username: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/\(username)/listeners"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func getInterestsProfilesForUsername(_ username: String, params: PageParams) -> Observable<PagedResults<Tag>> {
        let url = APIManager.baseURL + "/profiles/\(username)/interests"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func linkSocialAccountWithParams(_ params: SocialAccountLinkParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/profiles/me/link"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func unlinkSocialAccountWithParams(_ params: SocialAccountLinkParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/profiles/me/link"
        return APIGenericService.requestWithMethod(.DELETE, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func unlinkFacebookPage(_ params: SocialAccountLinkParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/profiles/me/facebook_page"
        return APIGenericService.requestWithMethod(.DELETE, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func linkFacebookPage(_ params: SocialAccountLinkParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/profiles/me/facebook_page"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func getMutualProfiles(_ params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/me/mutual_friends"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func getMutualContacts(_ params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/me/mutual_contacts"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .url, headers: ["Accept": "application/json"])
    }
    
    static func updateProfileContacts(_ params: ContactsParams) -> Observable<Void> {
        let url = APIManager.baseURL + "/profiles/me/contacts"
        return APIGenericService.basicRequestWithMethod(.PATCH, url: url, params: params, encoding: .json, headers: ["Accept": "application/json"])
    }
    
    static func getPagesForUsername(_ username: String, pageParams: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/\(username)/pages"
        return APIGenericService.requestWithMethod(.GET, url: url, params: pageParams, encoding: .url, headers: ["Accept": "application/json"])
    }
}
