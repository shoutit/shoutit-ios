//
//  SHSettingsTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKLoginKit
import Haneke

class SHSettingsTableViewModel: NSObject, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, GIDSignInDelegate{
    private let viewController: SHSettingsTableViewController
    private let shApiUser = SHApiUserService()
    private let shApiAuthService = SHApiAuthService()
    
    required init(viewController: SHSettingsTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let user = self.viewController.user {
            self.loadUserData(user)
        }
        
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
    
    // google Link Action
    func googleLinkAction () {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicatorView.frame = self.viewController.googleLinkButton.frame
        indicatorView.startAnimating()
        let superView = self.viewController.googleLinkButton.superview
        self.viewController.googleLinkButton.hidden = true
        superView?.addSubview(indicatorView)
        if let user = self.viewController.user?.linkedAccounts, let gplus = user.gplus {
            if(!gplus) {
                GIDSignIn.sharedInstance().delegate = self
                GIDSignIn.sharedInstance().signIn()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    indicatorView.removeFromSuperview()
                    self.viewController.googleLinkButton.hidden = false
                })
            } else {
                GIDSignIn.sharedInstance().signOut()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    indicatorView.removeFromSuperview()
                    self.viewController.googleLinkButton.hidden = false
                })
            }
        }
    }
    
    
    
    // facebook link Action
    func fbLinkAction () {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicatorView.frame = self.viewController.fbLinkButton.frame
        indicatorView.startAnimating()
        let superView = self.viewController.fbLinkButton.superview
        self.viewController.fbLinkButton.hidden = true
        superView?.addSubview(indicatorView)
        if let user = self.viewController.user?.linkedAccounts, let facebook = user.facebook {
            if(!facebook) {
                let login: FBSDKLoginManager = FBSDKLoginManager()
                login.logInWithReadPermissions(["public_profile", "email", "user_birthday"], fromViewController: viewController) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                    if (error != nil) {
                        log.info("Process error")
                    } else {
                        if result.isCancelled {
                            log.info("Cancelled")
                        } else {
                            log.info("Logged in")
                            self.setSelected(self.viewController.fbLinkButton, isSelected: true)
                            if((FBSDKAccessToken.currentAccessToken()) != nil) {
                                let params = self.shApiAuthService.getFacebookParams(FBSDKAccessToken.currentAccessToken().tokenString)
                                self.getOauthResponse(params)
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    indicatorView.removeFromSuperview()
                    self.viewController.fbLinkButton.hidden = false
                })
            } else {
                FBSDKLoginManager().logOut()
                self.setSelected(self.viewController.fbLinkButton, isSelected: false)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    indicatorView.removeFromSuperview()
                    self.viewController.fbLinkButton.hidden = false
                })
            }
        }
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewController.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if (indexPath.section == 1 && indexPath.row == 0) {
            if let user = self.viewController.user, let username = user.name {
                self.inviteViaMailWithText(NSLocalizedString("Check out ShoutIT app, http://www.shoutit.com", comment: "Check out ShoutIT app, http://www.shoutit.com"), subject: String(format: "%@ %@", arguments: [username, NSLocalizedString("Invitation to ShoutIT App from", comment: "Invitation to ShoutIT App from")]))
            }
        }
        
        if(indexPath.section == 1 && indexPath.row == 1) {
            self.inviteViaSMSWithText(NSLocalizedString("Check out ShoutIT app, http://www.shoutit.com", comment: "Check out ShoutIT app, http://www.shoutit.com"))
        }
        
        if(indexPath.section == 2 && indexPath.row == 0) {
            let ac = UIAlertController(title: NSLocalizedString("Sign Out", comment: "Sign Out"), message: NSLocalizedString("Are you sure you want to sign out?", comment: "Are you sure you want to sign out?"), preferredStyle: UIAlertControllerStyle.Alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                FBSDKLoginManager().logOut()
                GIDSignIn.sharedInstance().signOut()
                if let oauthToken = SHOauthToken.getFromCache() {
                    oauthToken.logOut()
                }
                Shared.stringCache.removeAll()
                SHOauthToken.goToLogin()
//                let appDelegate = UIApplication.sharedApplication().delegate
//                let loginVC = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier(Constants.ViewControllers.LOGIN_VC)
//                appDelegate?.window??.rootViewController = nil
//                appDelegate?.window??.rootViewController = loginVC
            }))
            self.viewController.presentViewController(ac, animated: true, completion: nil)
        }
        
        if (indexPath.section == 3 && indexPath.row == 0) {
            // Call this wherever you want to launch UserVoice
            UINavigationBar.appearance().backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_GREEN)
            UserVoice.presentUserVoiceInterfaceForParentViewController(self.viewController)
        }
        self.viewController.tableView.reloadData()
    }
    
    func inviteViaMailWithText(text: String, subject: String) {
        let controller = MFMailComposeViewController()
        if(MFMailComposeViewController.canSendMail()) {
            controller.setMessageBody(text, isHTML: false)
            controller.setSubject(subject)
            controller.mailComposeDelegate = self
            self.viewController.presentViewController(controller, animated: true, completion: nil)
        } else {
            SHProgressHUD.showError(NSLocalizedString("You cannot send an email from the app", comment: "You cannot send an email from the app"), maskType: .Black)
        }
    }
    
    func inviteViaSMSWithText(text: String) {
        let controller = MFMessageComposeViewController()
        if(MFMessageComposeViewController.canSendText()) {
            controller.body = text
            controller.messageComposeDelegate = self
            self.viewController.presentViewController(controller, animated: true, completion: nil)
        } else {
            SHProgressHUD.showError(NSLocalizedString("You cannot send a text message from the app", comment: "You cannot send a text message from the app"), maskType: .Black)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Private
    private func loadUserData(user: SHUser) {
        if let username = user.username {
            shApiUser.loadUserDetails(username, cacheResponse: { (shUser) -> Void in
                self.updateUI(shUser)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error getting user details \(error.localizedDescription)")
                    }
            }
        }
    }
    
    private func updateUI(shUser: SHUser) {
        self.viewController.user = shUser
        if let facebook = shUser.linkedAccounts?.facebook, let gplus = shUser.linkedAccounts?.gplus {
            self.setSelected(self.viewController.fbLinkButton, isSelected: facebook)
            self.setSelected(self.viewController.googleLinkButton, isSelected: gplus)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if (facebook) {
                    self.viewController.fbLinkButton.enabled = false
                    self.viewController.fbLinkButton.setTitle("PRIMARY", forState: UIControlState.Normal)
                    self.viewController.fbLinkButton.backgroundColor = UIColor.lightGrayColor()
                    self.viewController.fbLinkButton.layer.borderColor = UIColor.lightGrayColor().CGColor
                } else if (gplus) {
                    self.viewController.googleLinkButton.enabled = false
                    self.viewController.googleLinkButton.setTitle("PRIMARY", forState: UIControlState.Normal)
                    self.viewController.googleLinkButton.backgroundColor = UIColor.lightGrayColor()
                    self.viewController.googleLinkButton.layer.borderColor = UIColor.lightGrayColor().CGColor
                }
            }
        }
    }
    
    private func setSelected (button: UIButton, isSelected: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let color = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
            if(!isSelected) {
                button.setTitle("LINK", forState: UIControlState.Normal)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = color?.CGColor
                button.setTitleColor(color, forState: UIControlState.Normal)
                button.backgroundColor = UIColor.whiteColor()
            } else {
                button.setTitle("UNLINK", forState: UIControlState.Normal)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = color?.CGColor
                button.backgroundColor = color
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
            button.alpha = 1
        }
    }
    
    private func getOauthResponse(params: [String: AnyObject]) {
        SHProgressHUD.show(NSLocalizedString("SigningIn", comment: "Signing In..."))
        shApiAuthService.getOauthToken(params, cacheResponse: { (oauthToken) -> Void in
            // Do nothing here
            }) { (response) -> Void in
                SHProgressHUD.dismiss()
                switch(response.result) {
                case .Success(let oauthToken):
                    if let userId = oauthToken.user?.id, let accessToken = oauthToken.accessToken where !accessToken.isEmpty {
                        
                        SHMixpanelHelper.aliasUserId(userId)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let tabViewController = SHTabViewController()
                            self.viewController.navigationController?.pushViewController(tabViewController, animated: true)
                        })
                    } else {
                        // Login Failure
                        self.handleOauthResponseError()
                    }
                case .Failure:
                    self.handleOauthResponseError()
                }
        }
    }
    
    private func handleOauthResponseError() {
        log.debug("error logging in")
        // Clear OauthToken cache
        Shared.stringCache.removeAll()
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("LoginError", comment: "Could not log you in, please try again!"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
        self.viewController.presentViewController(alert, animated: true, completion: nil)
    }
}
