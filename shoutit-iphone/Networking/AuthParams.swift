//
//  AuthParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol AuthParams: Params {
    
    var grantType: String {get}
    var authParams: [String : AnyObject] {get}
}

extension AuthParams {
    
    var params: [String : AnyObject] {
        
        var commonParams: [String : AnyObject] = [
            "client_id": Constants.Authentication.clientID,
            "client_secret": Constants.Authentication.clientSecret,
            "grant_type": grantType
        ]
        
        for (key, value) in authParams {
            commonParams[key] = value
        }
        
        let coordinate = LocationManager.sharedInstance.currentLocation.coordinate
        var locationUserParams: [String : AnyObject] = ["location" : ["latitude": coordinate.latitude, "longitude": coordinate.longitude]]
        if let currentUserParams = commonParams["user"] as? [String : AnyObject] {
            for (key, value) in currentUserParams {
                locationUserParams[key] = value
            }
        }
        commonParams["user"] = locationUserParams
        
        if let mixPanelDistinctId = SHMixpanelHelper.getDistinctID() {
            commonParams["mixpanel_distinct_id"] = mixPanelDistinctId
        }
        
        return commonParams
    }
}

struct LoginParams: AuthParams {
    
    let email: String
    let password: String
    
    let grantType = "shoutit_signin"
    var authParams: [String : AnyObject] {
        return [
            "email": email,
            "password": password
        ]
    }
}

struct SignupParams: AuthParams {
    
    let name: String
    let email: String
    let password: String
    
    let grantType = "shoutit_signup"
    var authParams: [String : AnyObject] {
        return [
            "email": email,
            "password": password,
            "name": name
        ]
    }
}

struct LoginGuestParams: AuthParams {
    
    let grantType = "shoutit_guest"
    var apns: NSObject {
        if let token = Account.sharedInstance.apnsToken {
            return token as NSString
        }
        return NSNull()
    }
    
    var authParams: [String : AnyObject] {
        return [
            "user":
                ["push_tokens" : ["apns" : apns, "gcm" : NSNull()]] // example token. won't be neccessery later
        ]
    }
}

struct FacebookLoginParams: AuthParams {
    
    let token: String
    
    let grantType = "facebook_access_token"
    var authParams: [String : AnyObject] {
        return [
            "facebook_access_token": token
        ]
    }
}

struct GoogleLoginParams: AuthParams {
    
    let gplusCode: String
    
    let grantType = "gplus_code"
    var authParams: [String : AnyObject] {
        return [
            "gplus_code": gplusCode
        ]
    }
}

struct ResetPasswordParams: Params {
    
    let email: String
    
    var params: [String : AnyObject] {
        return ["email" : email]
    }
}
