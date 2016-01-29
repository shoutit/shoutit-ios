//
//  APIAuthService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class APIAuthService {
    
    private static let oauth2AccessTokenUrl = SHApiManager.sharedInstance.BASE_URL + "/oauth2/access_token"
    private static let authResetPasswordUrl = SHApiManager.sharedInstance.BASE_URL + "/auth/reset_password"
    
    // MARK: - Actions
    
    static func resetPassword(email: String, completionHandler: Response<SHSuccess, NSError> -> Void) {
        let params = [
            "email": email
        ]
        SHApiManager.sharedInstance.post(authResetPasswordUrl, params: params, completionHandler: completionHandler)
    }
    
    static func getOauthToken(params: [String: AnyObject]?, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        SHApiManager.sharedInstance.post(oauth2AccessTokenUrl, params: params, cacheKey: Constants.Cache.OauthToken, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    // MARK: - Params
    
    static func loginParamsWithEmail(email: String, password: String) -> [String : AnyObject] {
        return generateParamsWithGrantType("shoutit_signin",
            params: [
            "email": email,
            "password": password
            ])
    }
    
    static func signupParamsWithEmail(email: String, password: String, name: String) -> [String : AnyObject] {
        return generateParamsWithGrantType("shoutit_signup",
            params: [
            "email": email,
            "password": password,
            "name": name
            ])
    }
    
    static func facebookLoginParamsWithToken(facebookToken: String) -> [String : AnyObject] {
        return generateParamsWithGrantType("facebook_access_token",
            params: [
            "facebook_access_token": facebookToken
            ])
    }
    
    static func googleLoginParamsWithToken(token: String) -> [String : AnyObject] {
        return generateParamsWithGrantType("gplus_code", params: [
            "gplus_code": token
            ])
    }
    
    // MARK - Private
    
    static private func generateParamsWithGrantType(grantType: String, params: [String: AnyObject]? = nil) -> [String : AnyObject] {
        
        var commonParams: [String: AnyObject] = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": grantType
        ]

        if let params = params {
            for (key, value) in params {
                commonParams[key] = value
            }
        }
        
        if let coordinate = SHLocationManager.sharedInstance.getCurrentLocation()?.coordinate {
            commonParams["location"] = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        }
        
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            commonParams["mixpanel_distinct_id"] = mixPanelDistinctId
        }
        
        return commonParams
    }
    
}
