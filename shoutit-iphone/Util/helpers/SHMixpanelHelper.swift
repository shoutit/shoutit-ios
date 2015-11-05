//
//  SHMixpanelHelper.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 04/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Mixpanel

class SHMixpanelHelper: NSObject {

    static func openApp() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.SharedUserDefaults.MIXPANEL)
        let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN)
       // NSString* access_token = [[FXKeychain defaultKeychain] objectForKey:KEYCHAIN_ACCESS_TOKEN];
        
       // SHUser* user = [SHUser loadUserWithKey:USER_DEFAULTS_USER];
//        if (access_token && user) {
//            if(user.userID) {
//                mixpanel.identify(user.userID)
//                mixpanel.track("app_open", properties: ["signed_user": true])
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.SharedUserDefaults.MIXPANEL)
//            } else {
//                mixpanel.track("app_open", properties: ["signed_user": false])
//            }
//        } else {
//            mixpanel.track("app_open", properties: ["signed_user": false])
//        }
        
    }
    
    static func closeApp() {
        let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN)
       // SHUser* user = [SHUser loadUserWithKey:USER_DEFAULTS_USER];
//        if (user) {
//            if(user.userID) {
//                mixpanel.identify(user.userID)
//                mixpanel.track("app_leave", properties: ["signed_user": true])
//            }
//        } else {
//            mixpanel.track("app_leave", properties: ["signed_user": false])
//        }
        
    }
    
    static func aliasUserId(userId: String) {
        
        if(!NSUserDefaults.standardUserDefaults().boolForKey(Constants.SharedUserDefaults.MIXPANEL)) {
            let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN)
            if (!userId.isEmpty) {
                mixpanel.createAlias(userId, forDistinctID: mixpanel.distinctId)
                mixpanel.identify(mixpanel.distinctId)
            }
        }
        
    }
    
    static func identifyUserId(userId: String) {
        let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN)
        if (!userId.isEmpty) {
            mixpanel.identify(userId)
        }
    }
    
    static func getDistinctID() -> String? {
        if let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN) {
            return mixpanel.distinctId
        }
        return nil
    }
    
}
