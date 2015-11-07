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
    
    func getLoginParams(email: String, password: String) -> [String: AnyObject] {
        return generateParams(
            "shoutit_signin",
            params: [
                "email": email,
                "password": password
            ]
        )
    }
    
    func getSignUpParams(email: String, password: String, name: String) -> [String: AnyObject] {
        return generateParams(
            "shoutit_signup",
            params: [
                "email": email,
                "password": password,
                "name": name
            ]
        )
    }
    
    // Login Facebook
    func getFacebookParams(fbToken: String) -> [String: AnyObject] {
        return generateParams(
            "facebook_access_token",
            params: [
                "facebook_access_token": fbToken
            ]
        )
    }
    
    func resetPassword(email: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let param = [
            "email": email
        ]
        SHApiManager.sharedInstance.post(AUTH_RESET_PASSWORD, params: param, completionHandler: completionHandler)
    }
    
    func getOauthToken(params: [String: AnyObject]?, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    // MARK - private
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
