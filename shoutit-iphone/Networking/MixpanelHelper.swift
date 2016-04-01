//
//  MixpanelHelper.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Mixpanel

class MixpanelHelper: NSObject {
    
    static func openApp() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.SharedUserDefaults.MIXPANEL)
        if trackApp(true) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.SharedUserDefaults.MIXPANEL)
        }
    }
    
    static func closeApp() {
        trackApp(false)
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
        return Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN).distinctId
    }
    
    // MARK - Private
    private static func trackApp(isAppOpening: Bool) -> Bool {
        //let eventName = isAppOpening ? "app_open" : "app_leave"
        //let mixpanel = Mixpanel.sharedInstanceWithToken(Constants.MixPanel.MIXPANEL_TOKEN)
        //        if let oauthToken = SHOauthToken.getFromCache(),
        //            let accessToken = oauthToken.accessToken where accessToken.characters.count > 0,
        //            let user = oauthToken.user {
        //                mixpanel.identify(user.id)
        //                mixpanel.track(eventName, properties: ["signed_user": true])
        //                return true
        //        } else {
        //            mixpanel.track(eventName, properties: ["signed_user": false])
        //        }
        return false
    }
}