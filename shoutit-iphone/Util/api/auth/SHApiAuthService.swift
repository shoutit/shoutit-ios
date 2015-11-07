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
        let params = generateParams(email, password: password, grantType: "shoutit_signin")
        getAuthToken(params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    func performSignUp(email: String, password: String, name: String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        let params = generateParams(email, password: password, grantType: "shoutit_signup", name: name)
        getAuthToken(params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
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
    
    private func generateParams(email: String, password: String, grantType: String, name: String? = nil) -> [String : AnyObject] {
        var params = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": grantType,
            "email": email,
            "password": password
        ]
        if let userName = name {
            params["name"] = userName
        }
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            params["mixpanel_distinct_id"] = mixPanelDistinctId
        }
        return params
    }
    
    // Login- facebook
    func loginWithFacebook(fbToken:String,completionHandler: Response<SHOauthToken, NSError> ->Void) {
        var params = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": "facebook_access_token",
            "facebook_access_token": fbToken
        ]
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            params["mixpanel_distinct_id"] = mixPanelDistinctId
        }
       SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, completionHandler: completionHandler)
    }
    
}
