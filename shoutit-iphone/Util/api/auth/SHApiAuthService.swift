//
//  SHApiAuthService.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class SHApiAuthService: NSObject {

    private let OAUTH2_ACCESS_TOKEN = SHApiManager.sharedInstance.BASE_URL + "/oauth2/access_token"
    private let AUTH_RESET_PASSWORD = SHApiManager.sharedInstance.BASE_URL + "/auth/reset_password"
    
    func performLogin(email: String, password: String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        let params = generateParams(
            "shoutit_signin",
            params: [
                "email": email,
                "password": password
            ]
        )
        getAuthToken(params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func performSignUp(email: String, password: String, name: String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        let params = generateParams(
            "shoutit_signup",
            params: [
                "email": email,
                "password": password,
                "name": name
            ]
        )
        getAuthToken(params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    // Login- facebook
    func loginWithFacebook(fbToken:String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> ->Void) {
        let params = generateParams(
            "facebook_access_token",
            params: [
                "facebook_access_token": fbToken
            ]
        )
        SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, completionHandler: completionHandler)
    }
    
    func resetPassword(email: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let param = [
            "email": email
        ]
        SHApiManager.sharedInstance.post(AUTH_RESET_PASSWORD, params: param, completionHandler: completionHandler)
    }
    
    // MARK - private
    private func getAuthToken(params: [String: AnyObject]?, cacheKey: String? = nil, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    private func generateParams(grantType: String, params: [String: AnyObject]? = nil) -> [String : AnyObject] {
        var defaultParams: [String: AnyObject] = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": grantType
        ]
        if let params = params {
            for (key, value) in params {
                defaultParams[key] = value
            }
        }
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            defaultParams["mixpanel_distinct_id"] = mixPanelDistinctId
        }
        return defaultParams
    }
    
}
