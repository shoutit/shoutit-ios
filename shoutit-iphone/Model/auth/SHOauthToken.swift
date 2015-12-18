//
//  SHOauthToken.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 05/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import ObjectMapper
import Haneke

class SHOauthToken: Mappable {

    private(set) var accessToken: String?
    private(set) var expiresIn = Int.max
    private(set) var isNewSignUp = false
    private(set) var refreshToken: String?
    private(set) var scope: String?
    private(set) var tokenType: String?
    private(set) var user: SHUser?
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        accessToken         <- map["access_token"]
        expiresIn           <- map["expires_in"]
        isNewSignUp         <- map["new_signup"]
        refreshToken        <- map["refresh_token"]
        scope               <- map["scope"]
        tokenType           <- map["token_type"]
        user                <- map["user"]
    }
    
    func isSignedIn() -> Bool {
        if let token = self.accessToken where token.characters.count > 0 {
            return true
        }
        return false
    }
    
    func updateUser(user: SHUser?) {
        if let shUser = user {
            self.user = shUser
        }
        if let stringResponse = Mapper().toJSONString(self) {
            Shared.stringCache.set(value: stringResponse, key: Constants.Cache.OauthToken)
        }
        // TODO Throw an event that user is updated
    }
    
    static func goToLogin() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let loginVC = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier(Constants.ViewControllers.LOGIN_VC)
        appDelegate?.window??.rootViewController = nil
        appDelegate?.window??.rootViewController = loginVC
    }
    
    static func goToDiscover() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let tabViewController = SHTabViewController()
        tabViewController.selectedIndex = 1
        appDelegate?.window??.rootViewController = tabViewController
    }
    
    static func getFromCache() -> SHOauthToken? {
        var shOauthToken: SHOauthToken? = nil
        let semaphore = dispatch_semaphore_create(0)
        getFromCache { (oauthToken) -> () in
            shOauthToken = oauthToken
            dispatch_semaphore_signal(semaphore)
        }
        let loopStartTime = NSDate().timeIntervalSince1970
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) != 0) {
            if NSDate().timeIntervalSince1970 - loopStartTime > 0.2 {
                break
            }
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
        return shOauthToken
    }
    
    static func getFromCache(oauthToken: SHOauthToken? -> ()) {
        Shared.stringCache.fetch(key: Constants.Cache.OauthToken)
            .onSuccess({ (cachedString) -> () in
                if let shOauthToken = Mapper<SHOauthToken>().map(cachedString) {
                    oauthToken(shOauthToken)
                }
            }).onFailure { (error) -> () in
                oauthToken(nil)
        }
    }
    
    func logOut() {
        self.accessToken = ""
        self.tokenType = ""
        self.expiresIn = 0
        self.refreshToken = ""
        self.scope = ""
    }
}
