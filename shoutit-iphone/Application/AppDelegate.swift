//
//  AppDelegate.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import XCGLogger
import FBSDKCoreKit
import Fabric
import Crashlytics
import UIViewAppearanceSwift

// Initialize Logger as global instance
let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        applyAppearance()
        
        configureLoggingServices()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        PlacesGeocoder.setup()
        LocationManager.sharedInstance.startUpdatingLocation()
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // handle the URL that your application receives at the end of the authentication process -- Google
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            let fb  = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            let g = GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
            
            let ret = fb ? fb : (g ? g : false)
            return ret;
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        LocationManager.sharedInstance.stopUpdatingLocation()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        LocationManager.sharedInstance.startUpdatingLocation()
    }

    func applicationWillTerminate(application: UIApplication) {
//        SHMixpanelHelper.closeApp()
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

extension AppDelegate {
    
    func configureLoggingServices() {
        
        #if DEBUG
            log.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #else
            log.setup(.None, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #endif
        
//        Fabric.with([Crashlytics.self])
        SHAmazonAWS.configureS3()
//        SHMixpanelHelper.openApp()
        
        //UserVoice
        let config = UVConfig(site: "shoutit.uservoice.com")
        config.showForum = false
        config.topicId = 79840
        config.forumId = 290071
        UserVoice.initialize(config)
        UVStyleSheet.instance().navigationBarTintColor = UIColor.blackColor()
        
//        SHPusherManager.sharedInstance.handleNewMessage { (event) -> () in
//            let userInfo = ["object": event]
//            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.kMessagePushNotification, object: nil, userInfo: userInfo)
//        }
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
}
