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
import FBSDKCoreKit
import ShoutitKit
import Bolts
import PaperTrailLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let router = DPLDeepLinkRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        
        
        applyAppearance()
        configureLoggingServices()
        
        // fetch user account to update all stats etc.
        Account.sharedInstance.fetchUserProfile()
        
        configureGoogleLogin()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions ?? [:])
        
        MixpanelHelper.handleUserDidOpenApp()
        
        LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
        
        PlacesGeocoder.setup()
        
        configureAPS(application)
        
        configureURLCache()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionStarted), name: NSNotification.Name.AppseeSessionStarted, object: nil)
        
        Appsee.start(Constants.AppSee.appKey)
        
        var firstLaunch = false
        
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce") == false) {
            firstLaunch = true
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
        }
        
        if (launchOptions?[UIApplicationLaunchOptionsKey.url] == nil && firstLaunch) {
            FBSDKAppLinkUtility.fetchDeferredAppLink({ (url, error) in
                // to decide what needs to be done here, completion closure takes link from where app is installed
            })
            
            FBSDKAppLinkUtility.fetchDeferredAppInvite({ (url) in
                // to decide what needs to be done here, url - refferal
                let promoCode = FBSDKAppLinkUtility.appInvitePromotionCode(from: url)
                Account.sharedInstance.invitationCode = promoCode
            })
        }
        
        FBSDKAppEvents.activateApp()
        
        registerRoutes()
        
        guard let launch = launchOptions, let userInfo = launch[UIApplicationLaunchOptionsKey.remoteNotification] as? [String : Any], let userInfoData = userInfo["data"] as? [AnyHashable: Any] else {
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
    func application(_ application: UIApplication,
        open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if let deepLinkQueryItems = DeeplinkQueryParser().parse(url: url) {
            MixpanelHelper.handleDeeplinkDidOpenApp(queryParams: deepLinkQueryItems)
        }
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        let parsedUrl = BFURL.init(inboundURL: url, sourceApplication: sourceApplication)
        
        if ((parsedUrl?.appLinkData) != nil) {
            return self.router.handle(parsedUrl!.targetURL, withCompletion: nil)
        }
        
        return self.router.handle(url, withCompletion:nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        LocationManager.sharedInstance.stopUpdatingLocation()
        Account.sharedInstance.pusherManager.disconnect()
        MixpanelHelper.handleAppDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        LocationManager.sharedInstance.startUpdatingLocationIfPermissionsGranted()
        
        MixpanelHelper.handleUserDidOpenApp()
        
        if case .logged(let user)? = Account.sharedInstance.loginState {
            Account.sharedInstance.pusherManager.tryToConnect()
            Account.sharedInstance.facebookManager.checkExpiryDateWithProfile(user)
        }
        
        Account.sharedInstance.fetchUserProfile()
        
        RateApp.sharedInstance().registerLaunch()
    }
    
    // MARK: - Push notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    
        guard let currentUserId = Account.sharedInstance.user?.id else {
            return
        }
        
        guard userInfo["pushed_for"] as? String == currentUserId else {
            return
        }
        
        guard let userInfoData = userInfo["data"] as? [AnyHashable: Any] else {
            return
        }
        
        if application.applicationState == .inactive || application.applicationState == .background {
            handlePushNotificationData(userInfoData, dispatchAfter: 0)
        }
    }
    
    func handlePushNotificationData(_ data: [AnyHashable: Any], dispatchAfter: Double) {
        
        if let appPath = data["app_url"] as? String, let urlToOpen = URL(string:appPath) {
            
            let delayTime = DispatchTime.now() + Double(Int64(dispatchAfter * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.router.handle(urlToOpen, withCompletion:nil)
            }
            
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        Account.sharedInstance.apnsToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
}

// MARK: - Appearance

private extension AppDelegate {
    
    func configureGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = Constants.Google.clientID
        GIDSignIn.sharedInstance().serverClientID = Constants.Google.serverClientID
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/userinfo.email"]
//        GIDSignIn.sharedInstance().allowsSignInWithBrowser = true
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
//        GIDSignIn.sharedInstance().allowsSignInWithWebView = false
    }
    
    func configureLoggingServices() {
        Fabric.with([Crashlytics.self, Appsee.self])
        AmazonAWS.configureS3()
        
        //UserVoice
        guard let config = UVConfig(site: "shoutit.uservoice.com") else {
            assertionFailure("Could not read config file")
            return
        }
        
        config.showForum = false
        config.topicId = 79840
        config.forumId = 290071
        UserVoice.initialize(config)
        UVStyleSheet.instance().navigationBarTintColor = UIColor.black
        
        // Disable AutoLayout Constraints Warnings
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance() as RMPaperTrailLogger!
        paperTrailLogger?.host = "logs4.papertrailapp.com" //Your host here
        paperTrailLogger?.port = 33179 //Your port number here
        paperTrailLogger?.programName = "guest"
        
        DDLog.add(paperTrailLogger!)
        
        NewRelicAgent.start(withApplicationToken: Constants.NewRelic.appId)
        
    }
    
    func applyAppearance() {
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white,
                                                            NSFontAttributeName : UIFont.systemFont(ofSize: 20)]
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor(shoutitColor: .primaryGreen)
        UINavigationBar.appearance().barTintColor = UIColor(shoutitColor: .primaryGreen)
        UIBarButtonItem.appearance().tintColor = UIColor.white
    }
    
    func configureAPS(_ application: UIApplication) {
        
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "ANSWER_ACTION"
        textAction.title = "Answer"
        textAction.activationMode = .background
        textAction.isAuthenticationRequired = false
        textAction.isDestructive = true
        
        if #available(iOS 9.0, *) {
            textAction.behavior = .default
        } else {
            // Fallback on earlier versions
        }
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "VIDEO_CALL_CATEGORY"
        category.setActions([textAction], for: .default)
        category.setActions([textAction], for: .minimal)
        
        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func configureURLCache() {
        let URLCache = Foundation.URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        Foundation.URLCache.shared = URLCache
        
    }
}

extension AppDelegate {
    func registerRoutes() {
        
        let routableElements : [NavigationItem] = [.Home, .Discover, .Browse, .Search, .Chats, .PublicChats, .Conversation, .Settings, .Notifications, .Profile, .Shout, .CreateShout, .CreditsTransations, .StaticPage]
        
        for route in routableElements {
            self.router.register({ [weak self] (deeplink) in
                self?.routeToNavigationItem(route, withDeeplink: deeplink!)
            }, forRoute: route.rawValue)
        }
        
    }
    
    func routeToNavigationItem(_ navigationItem: NavigationItem, withDeeplink deeplink: DPLDeepLink) {
        
        guard let applicationMainController = self.window?.rootViewController as? ApplicationMainViewController else {
            return
        }
        
        guard let rootController = applicationMainController.childViewControllers.first as? RootController else {
            return
        }
        
        rootController.routeToNavigationItem(navigationItem, withDeeplink: deeplink)
    }
}

// Appsee
extension AppDelegate {
    
    func sessionStarted(_ notification: Foundation.Notification) {
        
        Crashlytics.sharedInstance().setObjectValue("https://dashboard.appsee.com/3rdparty/crashlytics/\(Appsee.generate3rdPartyID("Crashlytics", persistent: false))", forKey: "AppseeSessionUrl")
    }
    
}
