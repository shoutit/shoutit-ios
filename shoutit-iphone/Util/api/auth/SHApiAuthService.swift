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
    
    func performLogin(email: String, password: String, completionHandler: Response<AnyObject, NSError> -> Void) {
        let params = [
            "client_id": Constants.Authentication.SH_CLIENT_ID,
            "client_secret": Constants.Authentication.SH_CLIENT_SECRET,
            "grant_type": "shoutit_signin",
            "email": email,
            "password": password
        ]
        getAuthToken(params, completionHandler: completionHandler)
    }
    
    private func getAuthToken(params: [String: AnyObject]?, completionHandler: Response<AnyObject, NSError> -> Void) {
        SHApiManager.sharedInstance.post(OAUTH2_ACCESS_TOKEN, params: params, completionHandler: completionHandler)
    }
    
}
