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
    
    func performLogin(email: String, password: String, cacheKey: String, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        var params = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": "shoutit_signin",
            "email": email,
            "password": password
        ]
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            params["mixpanel_distinct_id"] = mixPanelDistinctId
        }
        getAuthToken(params, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
    private func getAuthToken(params: [String: AnyObject]?, cacheKey: String? = nil, cacheResponse: SHOauthToken -> Void, completionHandler: Response<SHOauthToken, NSError> -> Void) {
        SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, cacheKey: cacheKey, cacheResponse: cacheResponse, completionHandler: completionHandler)
    }
    
}
