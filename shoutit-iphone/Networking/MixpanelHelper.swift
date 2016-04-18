//
//  MixpanelHelper.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Mixpanel

class MixpanelHelper {
    
    #if STAGING
    private static let mixpanelToken  = "d2de0109a8de7237dede66874c7b8951"
    #else
    private static let mixpanelToken  = "c9d0a1dc521ac1962840e565fa971574"
    #endif
    private static let didOpenAppUserDefailt = "didOpenAppUserDefailt"
    
    struct Actions {
        static let appOpen = "app_open"
        static let appClose = "app_close"
    }
    
    private static var mixpanel: Mixpanel {
        return Mixpanel.sharedInstanceWithToken(MixpanelHelper.mixpanelToken)
    }
    
    private static var actionProperties: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["api_client"] = "shoutit-ios"
        p["signed_user"] = Account.sharedInstance.authData != nil
        if let user = Account.sharedInstance.user {
            p["is_guest"] = user.isGuest
        }
        return p
    }
    
    // MARK: - Interface
    
    static func handleUserDidOpenApp() {
        identifyUserIfLoggedIn()
        sendAppOpenEvent()
    }
    
    static func handleAppDidTerminate() {
        sendAppDidCloseEvent()
    }
    
    static func getDistictId() -> String {
        return mixpanel.distinctId
    }
    
    // MARK: - Helpers
    
    private static func identifyUserIfLoggedIn() {
        if let user = Account.sharedInstance.user {
            mixpanel.identify(user.id)
        }
    }
    
    private static func sendAppOpenEvent() {
        mixpanel.track(Actions.appOpen, properties: actionProperties)
    }
    
    private static func sendAppDidCloseEvent() {
        mixpanel.track(Actions.appClose, properties: actionProperties)
    }
}
