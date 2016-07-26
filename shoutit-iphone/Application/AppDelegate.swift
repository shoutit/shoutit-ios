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
import SwiftyBeaver
import FBSDKCoreKit
import ShoutitKit
import Bolts
import PaperTrailLumberjack

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let router = DPLDeepLinkRouter()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BuddyBuildSDK.setup()
        
        
        applyAppearance()
        configureLoggingServices()
        
        // fetch user account to update all stats etc.
        Account.sharedInstance.fetchUserProfile()
        
        configureGoogleLogin()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions ?? [:])
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(Constants.Aviary.clientID, clientSecret: Constants.Aviary.clientSecret, enableSignUp: true)
        PlacesGeocoder.setup()
        MixpanelHelper.handleUserDidOpenApp()
        LocationManager.sharedInstance.startUpdatingLocation()
        
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(Constants.Aviary.clientID, clientSecret: Constants.Aviary.clientSecret, enableSignUp: true)
        
        configureAPS(application)
        configureURLCache()
        
        var firstLaunch = false
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") == false) {
            firstLaunch = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsURLKey] == nil && firstLaunch) {
            FBSDKAppLinkUtility.fetchDeferredAppLink({ (url, error) in
                // to decide what needs to be done here, completion closure takes link from where app is installed
            })
            
            FBSDKAppLinkUtility.fetchDeferredAppInvite({ (url) in
                // to decide what needs to be done here, url - refferal
                let promoCode = FBSDKAppLinkUtility.appInvitePromotionCodeFromURL(url)
                Account.sharedInstance.invitationCode = promoCode
            })
        }
        
        FBSDKAppEvents.activateApp()
        
        registerRoutes()
        
        guard let launch = launchOptions, userInfo = launch[UIApplicationLaunchOptionsRemoteNotificationKey], userInfoData = userInfo["data"] as? [NSObject : AnyObject] else {
            return true
        }
        
        guard let currentUserId = Account.sharedInstance.user?.id else {
            return true
        }
        
        guard userInfo["pushed_for"] as? String == currentUserId else {
            return true
        }
        
        handlePushNotificationData(userInfoData, dispatchAfter: 2)
        
        return true
    }
    
    
    // handle the URL that your application receives at the end of the authentication process -- Google
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        if GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        let parsedUrl = BFURL.init(inboundURL: url, sourceApplication: sourceApplication)
        
        if ((parsedUrl.appLinkData) != nil) {
            return self.router.handleURL(parsedUrl.targetURL, withCompletion: nil)
        }
        
        return self.router.handleURL(url, withCompletion:nil)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        LocationManager.sharedInstance.stopUpdatingLocation()
        Account.sharedInstance.pusherManager.disconnect()
        MixpanelHelper.handleAppDidEnterBackground()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        LocationManager.sharedInstance.startUpdatingLocation()
        LocationManager.sharedInstance.triggerLocationUpdate()
        MixpanelHelper.handleUserDidOpenApp()
        if case .Logged(let user)? = Account.sharedInstance.loginState {
            Account.sharedInstance.pusherManager.tryToConnect()
            Account.sharedInstance.facebookManager.checkExpiryDateWithProfile(user)
        }
        
        Account.sharedInstance.fetchUserProfile()
    }
    
    // MARK: - Push notifications
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    
        guard let currentUserId = Account.sharedInstance.user?.id else {
            return
        }
        
        guard userInfo["pushed_for"] as? String == currentUserId else {
            return
        }
        
        guard let userInfoData = userInfo["data"] as? [NSObject : AnyObject] else {
            return
        }
        
        if application.applicationState == .Inactive || application.applicationState == .Background {
            handlePushNotificationData(userInfoData, dispatchAfter: 0)
        }
    }
    
    func handlePushNotificationData(data: [NSObject: AnyObject], dispatchAfter: Double) {
        
        if let appPath = data["app_url"] as? String, urlToOpen = NSURL(string:appPath) {
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(dispatchAfter * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.router.handleURL(urlToOpen, withCompletion:nil)
            }
            
            
        }
    }
    
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
        
        
        // Configure Swift Beaver
        let console = ConsoleDestination()  // log to Xcode Console
        let cloud = SBPlatformDestination(appID: "v6ggaZ", appSecret: "ckaIkfmgycLdD78fofhrc48Q6K7Rzpps", encryptionKey: "p8br20ubgBcorJlmlFiortCqtv1wnztd") // to cloud
        
        assert(log.addDestination(console))
        assert(log.addDestination(cloud))
    
        // Disable AutoLayout Constraints Warnings
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance() as RMPaperTrailLogger!
        paperTrailLogger.host = "logs4.papertrailapp.com" //Your host here
        paperTrailLogger.port = 33179 //Your port number here
        paperTrailLogger.programName = "\(version)-\(build)"
        
        DDLog.addLogger(paperTrailLogger)
        
    }
    
    func applyAppearance() {
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),
                                                            NSFontAttributeName : UIFont.systemFontOfSize(20)]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().backgroundColor = UIColor(shoutitColor: .PrimaryGreen)
        UINavigationBar.appearance().barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
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
    
    func configureURLCache() {
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
    }
}

extension AppDelegate {
    func registerRoutes() {
        
        let routableElements : [NavigationItem] = [.Home, .Discover, .Browse, .Search, .Chats, .PublicChats, .Conversation, .Settings, .Notifications, .Profile, .Shout, .CreateShout, .CreditsTransations]
        
        for route in routableElements {
            self.router.registerBlock({ [weak self] (deeplink) in
                self?.routeToNavigationItem(route, withDeeplink: deeplink)
            }, forRoute: route.rawValue)
        }
        
    }
    
    func routeToNavigationItem(navigationItem: NavigationItem, withDeeplink deeplink: DPLDeepLink) {
        
        guard let applicationMainController = self.window?.rootViewController as? ApplicationMainViewController else {
            return
        }
        
        guard let rootController = applicationMainController.childViewControllers.first as? RootController else {
            return
        }
        
        rootController.routeToNavigationItem(navigationItem, withDeeplink: deeplink)
    }
}
