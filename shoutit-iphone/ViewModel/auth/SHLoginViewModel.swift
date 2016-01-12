//
//  SHLoginViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Haneke
import MK

class SHLoginViewModel: NSObject, ViewControllerModelProtocol, GIDSignInDelegate, UITextViewDelegate, TextFieldDelegate{

    private var viewController: SHLoginViewController?
    private var socialViewController: SHSocialLoginViewController?
    private let webViewController = SHModalWebViewController()
    private let shApiAuthService = SHApiAuthService()
   
    required init(viewController: SHLoginViewController) {
        self.viewController = viewController
    }
    
    init(socialViewController: SHSocialLoginViewController) {
        self.socialViewController = socialViewController
    }
    
    func viewDidLoad() {
        self.setupText()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("validateInput:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
        self.viewController?.termsAndConditionsTextView?.delegate = self
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK - ViewController Methods
    func loginWithGplus() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginWithFacebook() {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email", "user_birthday"], fromViewController: viewController) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if (error != nil) {
                log.info("Process error \(error.localizedDescription)")
            } else {
                if result.isCancelled {
                    log.info("Cancelled")
                } else {
                    log.info("Logged in")
                    if((FBSDKAccessToken.currentAccessToken()) != nil) {
                        let params = self.shApiAuthService.getFacebookParams(FBSDKAccessToken.currentAccessToken().tokenString)
                        self.getOauthResponse(params)
                    }
                }
            }
        }
    }
    
    func performSignUp() {
        if validateAuthentication() {
            // Perform SignUp
            if let vc = self.viewController {
                let params = self.shApiAuthService.getSignUpParams(vc.signUpEmailOrUsername.text!, password: vc.signUpPassword.text!, name: vc.firstName.text! + " " + vc.lastNameTextField.text!)
                self.getOauthResponse(params)
            }
        }
    }
    
    func performLogin() {
        if validateAuthentication() {
            // Perform API Request
            // Perform Sign In
            if let vc = self.viewController {
                let params = self.shApiAuthService.getLoginParams(vc.signInEmailOrUsername.text!, password: vc.signInPassword.text!)
                self.getOauthResponse(params)
            }
        } else {
            
            log.debug("Incorrect Email or Password")
        }
    }
    
    func resetPassword() {
        if let emailTextField = self.viewController?.signInEmailOrUsername {
            if let email = emailTextField.text where !self.emailValidation(email) {
                self.displayErrorMessage(NSLocalizedString("EnterValidMail", comment: "Enter valid email."), view: self.viewController?.emailView)
                return
            }
            shApiAuthService.resetPassword(emailTextField.text!, completionHandler: { (response) -> Void in
                if response.result.isSuccess {
                    let ac = UIAlertController(title: NSLocalizedString("Success", comment: "Success"), message: NSLocalizedString("Password recovery email will be sent soon.", comment: "Password recovery email will be sent soon."), preferredStyle: UIAlertControllerStyle.Alert)
                    ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
                    self.viewController?.presentViewController(ac, animated: true, completion: nil)
                } else {
                    log.debug("Error sending the mail")
                }
            })
        }
    }
    
    func skipLogin () {
        SHOauthToken.goToDiscover()
    }
    
    func showPrivacy(viewController: UIViewController) {
        webViewController.presentFromViewController(viewController, withHTMLFile: "policy")
    }
    
    func showTerms(viewController: UIViewController) {
        webViewController.presentFromViewController(viewController, withHTMLFile: "tos")
    }
    
    func togglePassword() {
        if let vc = self.viewController {
            if vc.signUpView.hidden {
                vc.signInPassword.secureTextEntry = !vc.signInPassword.secureTextEntry
            } else {
                vc.signUpPassword.secureTextEntry = !vc.signUpPassword.secureTextEntry
            }
        }
    }
    
    func showUserVoice(viewController: UIViewController) {
        UserVoice.presentUserVoiceInterfaceForParentViewController(viewController)
    }
    
    // MARK - GoogleSignIn Delegate
    //handle the sign-in process -- Google
    func signIn(signIn: GIDSignIn?, didSignInForUser user: GIDGoogleUser?,
        withError error: NSError?) {
            GIDSignIn.sharedInstance().delegate = nil
            if error == nil, let serverAuthCode = user?.serverAuthCode {
                let params = shApiAuthService.getGooglePlusParams(serverAuthCode)
                self.getOauthResponse(params)
            } else {
                GIDSignIn.sharedInstance().signOut()
                log.debug("\(error?.localizedDescription)")
            }
    }

    func signIn(signIn: GIDSignIn?, didDisconnectWithUser user:GIDGoogleUser?,
        withError error: NSError?) {
            GIDSignIn.sharedInstance().delegate = nil
            log.verbose("Error getting Google Plus User")
    }
    
    // MARK - UITextViewDelegate
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        if let vc = self.viewController where url.scheme == "initial" {
            if(url.absoluteString.containsString("terms")) {
                self.showTerms(vc)
            } else if (url.absoluteString.containsString("privacy")) {
                self.showPrivacy(vc)
            } else if (url.absoluteString.containsString("rules")) {
                webViewController.presentFromViewController(vc, withHTMLFile: "rules")
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if let vc = self.viewController {
            if ((textField == vc.firstNameTextField) || (textField == vc.lastNameTextField)) {
                if let name = textField.text {
                    self.nameValidation(name)
                }
            } else if (textField == vc.signUpEmailOrUsername) {
                if let email = textField.text {
                    self.emailValidation(email)
                }
            } else if (textField == vc.signUpPassword) {
                if let password = textField.text {
                    self.passwordValidation(password)
                }
             }
//            else if (textField == vc.signInPassword) {
//                if let password = textField.text {
//                    self.passwordValidation(password)
//                }
//            }
        }
        return true
    }
    
    func validateInput (sender: NSNotification) {
        if let vc = self.viewController {
            self.viewController?.errorMessageLabel.hidden = true
            if let textField = sender.object as? TextField {
                if textField == vc.firstNameTextField {
                    if let firstName = vc.firstNameTextField.text {
                        if(!self.nameValidation(firstName)) {
                            self.displayErrorMessage(NSLocalizedString("FirstNameValidationError", comment: "Enter valid first name."), view: vc.firstNameView)
                            return
                        }
                    }
                } else if textField == vc.lastNameTextField {
                    if let lastName = vc.lastNameTextField.text {
                        if(!self.nameValidation(lastName)) {
                            self.displayErrorMessage(NSLocalizedString("LastNameValidationError", comment: "Enter valid last name."), view: vc.lastNameView)
                            return
                        }
                    }
                } else if textField == vc.signUpEmailOrUsername {
                    if let email = vc.signUpEmailOrUsername.text {
                        if(!self.emailValidation(email)) {
                            self.displayErrorMessage(NSLocalizedString("EnterValidMail", comment: "Enter valid email."), view: vc.emailView)
                            return
                        }
                    }
                } else if textField == vc.signUpPassword {
                    if let password = vc.signUpPassword.text {
                        if(!self.passwordValidation(password)) {
                            self.displayErrorMessage(NSLocalizedString("PasswordValidationError", comment: "Password characters limit should be between 6-20"), view: vc.passwordView)
                            return
                        }
                    }
                }
//                } else if textField == vc.signInEmailOrUsername {
//                    if let email = vc.signInEmailOrUsername.text {
//                        if(!self.emailValidation(email)) {
//                            self.displayErrorMessage(NSLocalizedString("EnterValidMail", comment: "Enter valid email."), view: vc.signInEmailView)
//                            return
//                        }
//                    }
                
//                else if textField == vc.signInPassword {
//                    if let password = vc.signInPassword.text {
//                        if(!self.passwordValidation(password)) {
//                            self.displayErrorMessage(NSLocalizedString("PasswordValidationError", comment: "Password characters limit should be between 6-20"), view: vc.signInPasswordView)
//                            return
//                        }
//                    }
//                }
            }
        }
    }
    
    // MARK - Private
    private func displayErrorMessage (text: String, view: UIView?) {
        if let vc = self.viewController {
            vc.errorMessageLabel.hidden = false
            vc.errorMessageLabel.text = text
            view?.layer.borderColor = MaterialColor.red.accent2.CGColor
        }
    }
    
    private func nameValidation(str : String) -> Bool {
        let regex = try! NSRegularExpression(pattern: Constants.RegEx.REGEX_FIRST_USER_NAME_LIMIT, options: [.CaseInsensitive])
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
    private func emailValidation(str : String) -> Bool {
        let regex = try! NSRegularExpression(pattern: Constants.RegEx.REGEX_EMAIL, options: [.CaseInsensitive])
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
    private func usernameValidation(str : String) -> Bool {
        let regex = try! NSRegularExpression(pattern: Constants.RegEx.REGEX_USER_NAME, options: [.CaseInsensitive])
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
    private func passwordValidation(str : String) -> Bool {
        let regex = try! NSRegularExpression(pattern: Constants.RegEx.REGEX_PASSWORD_LIMIT, options: [.CaseInsensitive])
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
    private func setupText() {
        if let attributedText = self.viewController?.termsAndConditionsTextView?.attributedText {
            let text = NSMutableAttributedString(attributedString: attributedText)
            text.addAttribute(NSLinkAttributeName, value: "initial://terms", range: (text.string as NSString).rangeOfString("Terms of Service"))
            text.addAttribute(NSLinkAttributeName, value: "initial://privacy", range: (text.string as NSString).rangeOfString("Privacy Policy"))
            text.addAttribute(NSLinkAttributeName, value: "initial://rules", range: (text.string as NSString).rangeOfString("Marketplace Rules"))
            self.viewController?.termsAndConditionsTextView?.editable = false
            self.viewController?.termsAndConditionsTextView?.linkTextAttributes = [
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSForegroundColorAttributeName: UIColor.grayColor()
            ]
            self.viewController?.termsAndConditionsTextView?.delaysContentTouches = false
            self.viewController?.termsAndConditionsTextView?.attributedText = text
        }
    }
    
    private func validateAuthentication() -> Bool {
        if let vc = self.viewController {
            if vc.signUpView.hidden {
                if let emailOrUsername = vc.signInEmailOrUsername.text where (!self.emailValidation(emailOrUsername) && !(self.usernameValidation(emailOrUsername))) {
                    self.displayErrorMessage(NSLocalizedString("EnterValidMailOrUsername", comment: "Enter valid email / username"), view: vc.signInEmailView)
                    if(emailOrUsername.isEmpty) {
                        return false
                    }
                    return false
                }
                if let password = vc.signInPassword.text where !self.passwordValidation(password) {
                    self.displayErrorMessage(NSLocalizedString("PasswordValidationError", comment: "Password characters limit should be between 6-20"), view: vc.signInPasswordView)
                    return false
                }
            } else {
                if let firstName = vc.firstNameTextField.text where !self.nameValidation(firstName) {
                    self.displayErrorMessage(NSLocalizedString("FirstNameValidationError", comment: "Enter valid first name."), view: vc.firstNameView)
                    return false
                }
                if let lastName = vc.lastNameTextField.text where !self.nameValidation(lastName) {
                    self.displayErrorMessage(NSLocalizedString("LastNameValidationError", comment: "Enter valid last name."), view: vc.lastNameView)
                    return false
                }
                if let email = vc.signUpEmailOrUsername.text where !self.emailValidation(email) {
                    self.displayErrorMessage(NSLocalizedString("EnterValidMail", comment: "Enter valid email."), view: vc.emailView)
                    return false
                }
                if let password = vc.signUpPassword.text where !self.passwordValidation(password) {
                    self.displayErrorMessage(NSLocalizedString("PasswordValidationError", comment: "Password characters limit should be between 6-20"), view: vc.passwordView)
                    return false
                }
            }
        }
        return true
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
                    // Login Success
                    // TODO
                    
//                    [[SHPusherManager sharedInstance]subscribeToEventsWithUserID:[[[SHLoginModel sharedModel] selfUser]userID]];
//                    if([[UIApplication sharedApplication]isRegisteredForRemoteNotifications])
//                    {
//                        NSData * savedToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
//                        if (savedToken != nil)
//                        {
//                            [[SHNotificationsModel getInstance] sendToken:savedToken];
//                        }
//                    }
                    SHMixpanelHelper.aliasUserId(userId)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let postSignupVC = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPostSignup)
                        self.viewController?.presentViewController(postSignupVC, animated: true, completion: nil)
                        //SHOauthToken.goToDiscover()
                        SHPusherManager.sharedInstance.subscribeToEventsWithUserID(userId)
                    })
                } else {
                    // Login Failure
                    self.handleOauthResponseError()
                }
            case .Failure:
                self.handleOauthResponseError()
                // TODO
                // Show Alert Dialog with the error message
                // Currently this is bad in the current iOS app
            }
        }
    }
    
    private func handleOauthResponseError() {
        log.debug("error logging in")
        // Clear OauthToken cache
        Shared.stringCache.removeAll()
        self.viewController?.errorMessageLabel.text = NSLocalizedString("LoginError", comment: "Could not log you in, please try again!")
//        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("LoginError", comment: "Could not log you in, please try again!"), preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
//        self.viewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
}
