//
//  MixpanelHelper.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Mixpanel

final class MixpanelHelper {
    
    #if STAGING
    private static let mixpanelToken  = "d2de0109a8de7237dede66874c7b8951"
    #elseif LOCAL
    private static let mixpanelToken  = "a5774a99b9068ae66129859421ade687"
    #else
    fileprivate static let mixpanelToken  = "c9d0a1dc521ac1962840e565fa971574"
    #endif
    
    fileprivate static let didOpenAppUserDefailt = "didOpenAppUserDefailt"
    
    struct Actions {
        static let appOpen = "app_open"
        static let appClose = "app_close"
    }
    
    fileprivate static var mixpanel: Mixpanel {
        return Mixpanel.sharedInstance(withToken: MixpanelHelper.mixpanelToken)
    }
    
    fileprivate static var actionProperties: [String : AnyObject] {
        var p: [String : AnyObject] = [:]
        p["api_client"] = "shoutit-ios" as AnyObject
        p["signed_user"] = Account.sharedInstance.isUserAuthenticated as AnyObject
        if let user = Account.sharedInstance.user {
            p["is_guest"] = user.isGuest as AnyObject
        }
        return p
    }
    
    // MARK: - Interface
    
    static func handleUserDidOpenApp() {
        identifyUserIfLoggedIn()
        sendAppOpenEvent()
    }
    
    static func handleAppDidEnterBackground() {
        sendAppDidCloseEvent()
    }
    
    static func getDistictId() -> String {
        return mixpanel.distinctId
    }
    
    // MARK: - Helpers
    
    fileprivate static func identifyUserIfLoggedIn() {
        if let user = Account.sharedInstance.user {
            mixpanel.identify(user.id)
        }
    }
    
    fileprivate static func sendAppOpenEvent() {
        mixpanel.track(Actions.appOpen, properties: actionProperties)
    }
    
    fileprivate static func sendAppDidCloseEvent() {
        mixpanel.track(Actions.appClose, properties: actionProperties)
    }
}
