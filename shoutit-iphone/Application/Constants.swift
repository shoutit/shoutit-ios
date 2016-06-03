//
//  Constants.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Google {
        static let clientID = "935842257865-lppn1neft859vr84flug604an2lh33dk.apps.googleusercontent.com"
        static let serverClientID = "935842257865-s6069gqjq4bvpi4rcbjtdtn2kggrvi06.apps.googleusercontent.com"
        static let GOOGLE_API_KEY = "AIzaSyBZsjPCMTtOFB79RsWn3oUGVPDImf4ceTU"
    }
    
    struct Aviary {
        static let clientSecret = "12f2bb3e-d7e5-43e0-b0b5-6eea40f855d8"
        static let clientID = "31c7e2be6b374423a80966a3489a93e2"
    }
    
    struct URL {
        static let ShoutItWebsite = "http://www.shoutit.com"
    }
    
    struct Authentication {
        static let clientID = "shoutit-ios"
        static let clientSecret = "209b7e713eca4774b5b2d8c20b779d91"
    }
    
    struct Defaults {
        static let apnsTokenKey = "apnsTokenKey"
        static let locationAutoUpdates = "locationAutoUpdates"
    }
    
    struct Notification {
        static let LocationUpdated  = ".notification.LocationUpdated"
        static let ShoutStarted  = ".notification.ShoutStarted"
        static let kMessagePushNotification = "kMessagePushNotification"
        static let ToggleMenuNotification = "ToggleMenuNotification"
        static let UserDidLogoutNotification = "UserDidLogoutNotification"
        static let IncomingCallNotification = "IncomingCallNotification"
        static let ShoutDeletedNotification = "ShoutDeletedNotification"
    }
    
    struct AWS {
        static let SH_S3_USER_NAME = "shoutit-ios"
        static let SH_S3_ACCESS_KEY_ID = "AKIAJW62O3PBJT3W3HJA"
        static let SH_S3_SECRET_ACCESS_KEY = "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"
        static let SH_AMAZON_SHOUT_BUCKET = "shoutit-shout-image-original"
        static let SH_AMAZON_USER_BUCKET = "shoutit-user-image-original"
        
        static let SH_AMAZON_URL = "https://s3-eu-west-1.amazonaws.com/"
        static let SH_AWS_SHOUT_URL = "https://shout-image.static.shoutit.com/"
        static let SH_AWS_USER_URL = "https://user-image.static.shoutit.com/"
    }
    
    struct Invite {
        static let inviteURL = "https://www.shoutit.com/app"
        static let inviteText = NSLocalizedString("Buy & Sell while Chatting on #Shoutit App! Get it on shoutit.com/app", comment: "")
        static let facebookURL = "https://fb.me/1224908360855680"
    }
}

struct Platform {
    
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
    
    static var isRTL: Bool {
        return UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft
    }
}
