//
//  Constants.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

public struct Constants {
    
    public struct Google {
        public static let clientID = "935842257865-lppn1neft859vr84flug604an2lh33dk.apps.googleusercontent.com"
        public static let serverClientID = "935842257865-s6069gqjq4bvpi4rcbjtdtn2kggrvi06.apps.googleusercontent.com"
        public static let GOOGLE_API_KEY = "AIzaSyBZsjPCMTtOFB79RsWn3oUGVPDImf4ceTU"
    }
    
    public struct Aviary {
        public static let clientSecret = "12f2bb3e-d7e5-43e0-b0b5-6eea40f855d8"
        public static let clientID = "31c7e2be6b374423a80966a3489a93e2"
    }
    
    public struct FacebookAudience {
        #if STAGING
        public static let detailAdID = "1151546964858487_1259641220715727"
        public static let collectionAdID = "1151546964858487_1245960495417133"
        #else
        public static let detailAdID = "353625811317277_1259608590718990"
        public static let collectionAdID = "353625811317277_1245949345418248"
        #endif
    }
    
    public struct NewRelic {
        #if STAGING
        public static let appId = "AA9e7a6abfb318f478c0087b01a356641a16e2fd71"
        #elseif LOCAL
        public static let appId = "AA9e7a6abfb318f478c0087b01a356641a16e2fd71"
        #else
        public static let appId = "AAcbc05e7a42d552ab0640b06042072214972a32d2"
        #endif
        
    }
    
    public struct URL {
        public static let ShoutItWebsite = "http://www.shoutit.com"
    }
    
    public struct Authentication {
        public static let clientID = "shoutit-ios"
        public static let clientSecret = "209b7e713eca4774b5b2d8c20b779d91"
    }
    
    public struct Defaults {
        public static let apnsTokenKey = "apnsTokenKey"
        public static let locationAutoUpdates = "locationAutoUpdates"
    }
    
    public struct Notification {
        public static let LocationUpdated  = ".notification.LocationUpdated"
        public static let ShoutStarted  = ".notification.ShoutStarted"
        public static let kMessagePushNotification = "kMessagePushNotification"
        public static let ToggleMenuNotification = "ToggleMenuNotification"
        public static let UserDidLogoutNotification = "UserDidLogoutNotification"
        public static let IncomingCallNotification = "IncomingCallNotification"
        public static let ShoutDeletedNotification = "ShoutDeletedNotification"
        public static let RootControllerShouldOpenNavigationItem = "RootControllerShouldOpenNavigationItem" 
    }
    
    public struct AWS {
        public static let SH_S3_USER_NAME = "shoutit-ios"
        public static let SH_S3_ACCESS_KEY_ID = "AKIAJW62O3PBJT3W3HJA"
        public static let SH_S3_SECRET_ACCESS_KEY = "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"
        public static let SH_AMAZON_SHOUT_BUCKET = "shoutit-shout-image-original"
        public static let SH_AMAZON_USER_BUCKET = "shoutit-user-image-original"
        
        public static let SH_AMAZON_URL = "https://s3-eu-west-1.amazonaws.com/"
        public static let SH_AWS_SHOUT_URL = "https://shout-image.static.shoutit.com/"
        public static let SH_AWS_USER_URL = "https://user-image.static.shoutit.com/"
    }
    
    public struct Invite {
        public static let inviteURL = "https://www.shoutit.com/app"
        public static let inviteText = NSLocalizedString("Buy & Sell while Chatting on #Shoutit App! Get it on shoutit.com/app", comment: "Invite message content")
        public static let facebookURL = "https://fb.me/1224908360855680"
    }
}

public struct Platform {
    
    public static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
    
    public static var isRTL: Bool {
        return UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft
    }
}
