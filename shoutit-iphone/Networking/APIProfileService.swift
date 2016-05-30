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

final class APIProfileService {
    
    static func searchProfileWithParams(params: SearchParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL)
    }
    
    static func listen(listen: Bool, toProfileWithUsername username: String) -> Observable<Void> {
        let url = APIManager.baseURL + "/profiles/\(username)/listen"
        let method: Alamofire.Method = listen ? .POST : .DELETE
        return APIGenericService.basicRequestWithMethod(method, url: url, params: NopParams(), encoding: .URL, headers: nil)
    }
    
    static func retrieveProfileWithUsername(username: String) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func retrieveProfileWithTwilioUsername(twilio: String) -> Observable<Profile> {
        let url = APIManager.baseURL + "/twilio/profile?identity=\(twilio)"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
    }
    
    static func editUserWithUsername(username: String, withParams params: EditProfileParams) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON)
    }
    
    static func nullifyPushTokens() -> Observable<Void> {
        let url = APIManager.baseURL + "/profiles/me"
        let tokens = PushTokens(apns: nil, gcm: nil)
        let params = APNParams(tokens: tokens)
        return APIGenericService.basicRequestWithMethod(.PATCH, url: url, params: params, encoding: .JSON)
    }
    
    static func updateAPNsWithUsername<T: Decodable where T == T.DecodedType, T: User>(username: String, withParams params: APNParams) -> Observable<T> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON)
    }
    
    static func editEmailForUserWithUsername(username: String, withEmailParams params: EmailParams) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/\(username)"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON)
    }
    
    static func homeShoutsWithParams(params: FilteredShoutsParams) -> Observable<[Shout]> {
        let url = APIManager.baseURL + "/profiles/me/home"
        return APIGenericService.requestWithMethod(.GET,
                                                   url: url,
                                                   params: params,
                                                   encoding: .URL,
                                                   responseJsonPath: ["results"],
                                                   headers: ["Accept": "application/json"])
    }
    
    static func getListeningProfilesForUsername(username: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/\(username)/listening"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func getListenersProfilesForUsername(username: String, params: PageParams) -> Observable<PagedResults<Profile>> {
        let url = APIManager.baseURL + "/profiles/\(username)/listeners"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func getInterestsProfilesForUsername(username: String, params: PageParams) -> Observable<PagedResults<Tag>> {
        let url = APIManager.baseURL + "/profiles/\(username)/interests"
        return APIGenericService.requestWithMethod(.GET, url: url, params: params, encoding: .URL, headers: ["Accept": "application/json"])
    }
    
    static func linkSocialAccountWithParams(params: SocialAccountLinkParams) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/me/link"
        return APIGenericService.requestWithMethod(.PATCH, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
    
    static func unlinkSocialAccountWithParams(params: SocialAccountLinkParams) -> Observable<DetailedProfile> {
        let url = APIManager.baseURL + "/profiles/me/link"
        return APIGenericService.requestWithMethod(.DELETE, url: url, params: params, encoding: .JSON, headers: ["Accept": "application/json"])
    }
}