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

// Initialize Logger as global instance
let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Setup Logger accourding to env variables
        #if DEBUG
            log.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #else
            log.setup(.None, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #endif
        
        Fabric.with([Crashlytics.self])
        SHAmazonAWS.configureS3()
        SHMixpanelHelper.openApp()
        
        // Initialize sign-in
        // let configureError: NSError?
        // GGLContext.sharedInstance().configureWithError(&configureError)
        // assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        if let cachedOauthToken = SHOauthToken.getFromCache() where cachedOauthToken.isSignedIn() {
            // User Already Signed In
            let tabViewController = SHTabViewController()
            self.window?.rootViewController = tabViewController
            // TODO get discover items
            // TODO if we get user not authenticated, then we need refresh user's token and get the updated token
        } else {
            // Not Signed In
        }
        
        SHLocationManager.sharedInstance.startUpdating()
        
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

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SHLocationManager.sharedInstance.stopUpdating()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        SHLocationManager.sharedInstance.startUpdating()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        SHMixpanelHelper.closeApp()
        SHLocationManager.sharedInstance.stopUpdating()
    }

}
