//
//  SHLoginPopupViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/14/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Haneke

class SHLoginPopupViewModel: NSObject, GIDSignInDelegate {

    private let viewController: SHLoginPopupViewController
    private var loginViewController: SHLoginViewController?
    private var socialViewController: SHSocialLoginViewController?
    private let webViewController = SHModalWebViewController()
    
    required init(viewController: SHLoginPopupViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    // MARK - GoogleSignIn Delegate
    //handle the sign-in process -- Google
    func signIn(signIn: GIDSignIn?, didSignInForUser user: GIDGoogleUser?,
        withError error: NSError?) {
//            GIDSignIn.sharedInstance().delegate = nil
//            if error == nil, let serverAuthCode = user?.serverAuthCode {
//                let params = shApiAuthService.getGooglePlusParams(serverAuthCode)
//                self.getOauthResponse(params)
//            } else {
//                GIDSignIn.sharedInstance().signOut()
//                log.debug("\(error?.localizedDescription)")
//            }
    }
    
    func signIn(signIn: GIDSignIn?, didDisconnectWithUser user:GIDGoogleUser?,
        withError error: NSError?) {
            GIDSignIn.sharedInstance().delegate = nil
            log.verbose("Error getting Google Plus User")
    }
    
    // MARK - ViewController Methods
    func loginWithGplus() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginWithFacebook() {
//        let login: FBSDKLoginManager = FBSDKLoginManager()
//        login.logInWithReadPermissions(["public_profile", "email", "user_birthday"], fromViewController: viewController) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
//            if (error != nil) {
//                log.info("Process error \(error.localizedDescription)")
//            } else {
//                if result.isCancelled {
//                    log.info("Cancelled")
//                } else {
//                    log.info("Logged in")
//                    if((FBSDKAccessToken.currentAccessToken()) != nil) {
//                        let params = self.shApiAuthService.getFacebookParams(FBSDKAccessToken.currentAccessToken().tokenString)
//                        self.getOauthResponse(params)
//                    }
//                }
//            }
//        }
    }
    
    //private
    private func getOauthResponse(params: [String: AnyObject]) {
//        SHProgressHUD.show(NSLocalizedString("SigningIn", comment: "Signing In..."))
//        shApiAuthService.getOauthToken(params, cacheResponse: { (oauthToken) -> Void in
//            // Do nothing here
//            }) { (response) -> Void in
//                SHProgressHUD.dismiss()
//                switch(response.result) {
//                case .Success(let oauthToken):
//                    if let userId = oauthToken.user?.id, let accessToken = oauthToken.accessToken where !accessToken.isEmpty {
//                        // Login Success
//                        // TODO
//                        
//                        //                    [[SHPusherManager sharedInstance]subscribeToEventsWithUserID:[[[SHLoginModel sharedModel] selfUser]userID]];
//                        //                    if([[UIApplication sharedApplication]isRegisteredForRemoteNotifications])
//                        //                    {
//                        //                        NSData * savedToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
//                        //                        if (savedToken != nil)
//                        //                        {
//                        //                            [[SHNotificationsModel getInstance] sendToken:savedToken];
//                        //                        }
//                        //                    }
//                        SHMixpanelHelper.aliasUserId(userId)
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            if let currentVC = self.loginViewController {
//                                if !currentVC.signUpView.hidden {
//                                    self.showPostSignUpScreen()
//                                } else {
//                                    SHOauthToken.goToDiscover()
//                                }
//                                
//                            } else if let _ = self.socialViewController {
//                                self.showPostSignUpScreen()
//                            } else {
//                                self.showPostSignUpScreen()
//                            }
//                            SHPusherManager.sharedInstance.subscribeToEventsWithUserID(userId)
//                        })
//                    } else {
//                        // Login Failure
//                        self.handleOauthResponseError(NSLocalizedString("LoginError", comment: "Could not log you in, please try again!"))
//                    }
//                case .Failure(let error):
//                    self.handleOauthResponseError(error.localizedDescription)
//                    // TODO
//                    // Show Alert Dialog with the error message
//                    // Currently this is bad in the current iOS app
//                }
//        }
    }
    
    private func showPostSignUpScreen () {
        let postSignupVC = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPostSignup)
        self.viewController.presentViewController(postSignupVC, animated: true, completion: nil)
    }
    
    private func handleOauthResponseError(error: String) {
        log.debug("error logging in")
        // Clear OauthToken cache
        Shared.stringCache.removeAll()
    }
}
