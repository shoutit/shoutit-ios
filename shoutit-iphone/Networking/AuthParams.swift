//
//  AuthParams.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 04.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import CoreLocation

public protocol AuthParams: Params {
    
    var grantType: String {get}
    var authParams: [String : AnyObject] {get}
    var mixPanelDistinctId: String {get set}
    var currentUserCoordinates: CLLocationCoordinate2D {get set}
}

extension AuthParams {
    
    public var params: [String : AnyObject] {
        
        var commonParams: [String : AnyObject] = [
            "client_id": Constants.Authentication.clientID,
            "client_secret": Constants.Authentication.clientSecret,
            "grant_type": grantType
        ]
        
        for (key, value) in authParams {
            commonParams[key] = value
        }
        
        let coordinate = currentUserCoordinates
        
        var locationUserParams: [String : AnyObject] = ["location" : ["latitude": coordinate.latitude, "longitude": coordinate.longitude]]
        if let currentUserParams = commonParams["profile"] as? [String : AnyObject] {
            for (key, value) in currentUserParams {
                locationUserParams[key] = value
            }
        }
        commonParams["profile"] = locationUserParams
        commonParams["mixpanel_distinct_id"] = mixPanelDistinctId
        
        return commonParams
    }
}

public struct LoginParams: AuthParams {
    public let email: String
    public let password: String
    
    public let grantType = "shoutit_login"
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public init(email: String, password: String, mixPanelDistinctId: String, currentUserCoordinates: CLLocationCoordinate2D) {
        self.email = email
        self.password = password
        self.mixPanelDistinctId = mixPanelDistinctId
        self.currentUserCoordinates = currentUserCoordinates
    }
    
    public var authParams: [String : AnyObject] {
        return [
            "email": email,
            "password": password
        ]
    }
}

public struct SignupParams: AuthParams {
    
    public let name: String
    public let email: String
    public let password: String
    
    public let grantType = "shoutit_signup"
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public init(name: String, email: String, password: String, mixPanelDistinctId: String, currentUserCoordinates: CLLocationCoordinate2D) {
        self.name = name
        self.email = email
        self.password = password
        self.mixPanelDistinctId = mixPanelDistinctId
        self.currentUserCoordinates = currentUserCoordinates
    }
    
    public var authParams: [String : AnyObject] {
        return [
            "email": email,
            "password": password,
            "name": name
        ]
    }
}

public struct LoginGuestParams: AuthParams {
    
    public let grantType = "shoutit_guest"
    public var apns: NSObject?
//    {
//        if let token = Account.sharedInstance.apnsToken {
//            return token as NSString
//        }
//        return NSNull()
//    }
    
    public init(apns: NSObject?, mixPanelId: String, currentUserLocation: CLLocationCoordinate2D) {
        self.apns = apns
        self.mixPanelDistinctId = mixPanelId
        self.currentUserCoordinates = currentUserLocation
    }
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public var authParams: [String : AnyObject] {
        return [
            "profile":
                ["push_tokens" : ["apns" : apns ?? NSNull()]]
        ]
    }
}

public struct FacebookLoginParams: AuthParams {
    
    public let token: String
    
    public let grantType = "facebook_access_token"
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public var authParams: [String : AnyObject] {
        return [
            "facebook_access_token": token
        ]
    }
    
    public init(token: String, mixPanelDistinctId: String, currentUserCoordinates: CLLocationCoordinate2D) {
        self.token = token
        self.mixPanelDistinctId = mixPanelDistinctId
        self.currentUserCoordinates = currentUserCoordinates
    }
}

public struct GoogleLoginParams: AuthParams {
    
    public let gplusCode: String
    
    public let grantType = "gplus_code"
    
    public var mixPanelDistinctId: String
    public var currentUserCoordinates: CLLocationCoordinate2D
    
    public var authParams: [String : AnyObject] {
        return [
            "gplus_code": gplusCode
        ]
    }
    
    public init(gplusCode: String, mixPanelDistinctId: String, currentUserCoordinates: CLLocationCoordinate2D) {
        self.gplusCode = gplusCode
        self.mixPanelDistinctId = mixPanelDistinctId
        self.currentUserCoordinates = currentUserCoordinates
    }
}

public struct ResetPasswordParams: Params {
    
    public let email: String
    
    public var params: [String : AnyObject] {
        return ["email" : email]
    }
    
    public init(email: String) {
        self.email = email
    }
}
