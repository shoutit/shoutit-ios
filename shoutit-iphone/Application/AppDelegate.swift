//
//  AppDelegate.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics
import UIViewAppearanceSwift
import Timberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Timberjack.register()
        Timberjack.logStyle = .Verbose
        
        applyAppearance()
        configureGoogleLogin()
        configureLoggingServices()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        PlacesGeocoder.setup()
        MixpanelHelper.handleUserDidOpenApp()
        LocationManager.sharedInstance.startUpdatingLocation()
        
        configureAPS(application)
        
        // fetch user account to update all stats etc.
        Account.sharedInstance.fetchUserProfile()
        
        return true
    }
    
    
    // handle the URL that your application receives at the end of the authentication process -- Google
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            let fb  = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            let g = GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
            
            return fb ? fb : (g ? g : false)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        LocationManager.sharedInstance.stopUpdatingLocation()
        
        
        PusherClient.sharedInstance.disconnect()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        LocationManager.sharedInstance.startUpdatingLocation()
        LocationManager.sharedInstance.triggerLocationUpdate()
        if Account.sharedInstance.isUserLoggedIn {
            PusherClient.sharedInstance.connect()
        }
        
        Account.sharedInstance.fetchUserProfile()
    }

    func applicationWillTerminate(application: UIApplication) {
        MixpanelHelper.handleAppDidTerminate()
    }
    
    // MARK: - Push notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
        Account.sharedInstance.apnsToken = token
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
}

// MARK: - Appearance

private extension AppDelegate {
    
    func configureGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = Constants.Google.clientID
        GIDSignIn.sharedInstance().serverClientID = Constants.Google.serverClientID
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/userinfo.email"]
        GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().allowsSignInWithWebView = true
    }
    
    func configureLoggingServices() {
        Fabric.with([Crashlytics.self])
        AmazonAWS.configureS3()
        
        //UserVoice
        let config = UVConfig(site: "shoutit.uservoice.com")
        config.showForum = false
        config.topicId = 79840
        config.forumId = 290071
        UserVoice.initialize(config)
        UVStyleSheet.instance().navigationBarTintColor = UIColor.blackColor()
    }
    
    func applyAppearance() {
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),
                                                            NSFontAttributeName : UIFont.systemFontOfSize(20)]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        if #available(iOS 9.0, *) {
            UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LoginNavigationViewController.self]).tintColor = UIColor(shoutitColor: .PrimaryGreen)
            UINavigationBar.appearanceWhenContainedInInstancesOfClasses([LoginNavigationViewController.self]).titleTextAttributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .PrimaryGreen)]
        } else {
            UINavigationBar.appearanceWhenContainedWithin(LoginNavigationViewController.self).tintColor = UIColor(shoutitColor: .PrimaryGreen)
            UINavigationBar.appearanceWhenContainedWithin(LoginNavigationViewController.self).titleTextAttributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .PrimaryGreen)]
        }
    }
    
    func configureAPS(application: UIApplication) {
        
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "ANSWER_ACTION"
        textAction.title = "Answer"
        textAction.activationMode = .Background
        textAction.authenticationRequired = false
        textAction.destructive = true
        
        if #available(iOS 9.0, *) {
            textAction.behavior = .Default
        } else {
            // Fallback on earlier versions
        }
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "VIDEO_CALL_CATEGORY"
        category.setActions([textAction], forContext: .Default)
        category.setActions([textAction], forContext: .Minimal)
        
        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
}
