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

class SHLoginViewModel: NSObject, ViewControllerModelProtocol, GIDSignInDelegate, UITextViewDelegate {

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
        
        self.viewController?.termsAndConditionsTextView?.delegate = self
        self.setUpValidations()
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
                let params = self.shApiAuthService.getSignUpParams(vc.signUpEmailOrUsername.text!, password: vc.signUpPassword.text!, name: vc.firstname.text! + " " + vc.lastname.text!)
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
            if(!emailTextField.validate()) {
                emailTextField.tapOnError()
                return
            }
            emailTextField.resignFirstResponder()
            if(emailTextField.text == "") {
                let ac = UIAlertController(title: NSLocalizedString("EmailNotSet", comment: "Email not set") , message: NSLocalizedString("PleaseEnterTheEmail", comment: "Please enter the email."), preferredStyle: UIAlertControllerStyle.Alert)
                self.viewController?.presentViewController(ac, animated: true, completion: nil)
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
//        let tabViewController = SHTabViewController()
//        tabViewController.selectedIndex = 1
//        self.viewController.navigationController?.pushViewController(tabViewController, animated: true)
        SHOauthToken.goToDiscover()
    }
    
    func showPrivacy(viewController: UIViewController) {
        webViewController.presentFromViewController(viewController, withHTMLFile: "policy")
    }
    
    func showTerms(viewController: UIViewController) {
        webViewController.presentFromViewController(viewController, withHTMLFile: "tos")
    }
    
    func showUserVoice(viewController: UIViewController) {
        UserVoice.presentUserVoiceInterfaceForParentViewController(viewController)
    }
    
    // MARK - Selectors
    func textFieldChanged(textField: TextFieldValidator) {
        textField.validate()
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
    
    // MARK - Private
    private func setUpValidations() {
        if let vc = self.viewController {
            vc.signInEmailOrUsername.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.signInEmailOrUsername.presentInView = vc.view
            vc.signInPassword.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.signInPassword.presentInView = vc.view
            vc.signUpEmailOrUsername.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.signUpEmailOrUsername.presentInView = vc.view
            vc.signUpPassword.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.signUpPassword.presentInView = vc.view
            vc.firstname.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.firstname.presentInView = vc.view
            vc.lastname.addTarget(self, action: "textFieldChanged:", forControlEvents: UIControlEvents.EditingChanged)
            vc.lastname.presentInView = vc.view
            vc.signInEmailOrUsername.addRegx(Constants.RegEx.REGEX_FIRST_USER_NAME_LIMIT, withMsg: NSLocalizedString("EnterValidMailOrUsername", comment: "Enter valid email or username."))
            vc.signUpEmailOrUsername.addRegx(Constants.RegEx.REGEX_EMAIL, withMsg: NSLocalizedString("EnterValidMail", comment: "Enter valid email."))
            vc.signInPassword.addRegx(Constants.RegEx.REGEX_PASSWORD_LIMIT, withMsg: NSLocalizedString("PasswordValidationError", comment: "Password charaters limit should be come between 6-20"))
            vc.signUpPassword.addRegx(Constants.RegEx.REGEX_PASSWORD_LIMIT, withMsg: NSLocalizedString("PasswordValidationError", comment: "Password charaters limit should be come between 6-20"))
            vc.firstname.addRegx(Constants.RegEx.REGEX_FIRST_USER_NAME_LIMIT, withMsg: NSLocalizedString("FirstNameValidationError", comment: "Enter valid first name."))
            vc.firstname.addRegx(Constants.RegEx.REGEX_LAST_USER_NAME_LIMIT, withMsg: NSLocalizedString("LastNameValidationError", comment: "Enter valid last name."))
        }
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
                if let emailTextField = vc.signInEmailOrUsername where !validateEmail(emailTextField) {
                    return false
                }
                if let passwordTextField = vc.signInPassword where !validatePassword(passwordTextField){
                    return false
                }
            } else {
                if let nameTextField = vc.firstname where !validateName(nameTextField, title: NSLocalizedString("FirstNameNotSet", comment: "First Name not set"), message: NSLocalizedString("PleaseEnterFirstName", comment: "Please enter the first name.")) {
                    return false
                }
                if let nameTextField = vc.lastname where !validateName(nameTextField, title: NSLocalizedString("LastNameNotSet", comment: "Last Name not set"), message: NSLocalizedString("PleaseEnterLastName", comment: "Please enter the last name.")) {
                    return false
                }
                if let emailTextField = vc.signUpEmailOrUsername where !validateEmail(emailTextField) {
                    return false
                }
                if let passwordTextField = vc.signUpPassword where !validatePassword(passwordTextField){
                    return false
                }
            }
        }
        return true
    }
    
    private func validateName(nameTextField: TextFieldValidator, title: String, message: String) -> Bool {
        if(!nameTextField.validate()) {
            nameTextField.tapOnError()
            return false
        }
        nameTextField.resignFirstResponder()
        
        if(nameTextField.text == "") {
            let ac = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert
            )
            self.viewController?.presentViewController(ac, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func validatePassword(passwordTextField: TextFieldValidator) -> Bool {
        if(!passwordTextField.validate()) {
            passwordTextField.tapOnError()
            return false
        }
        passwordTextField.resignFirstResponder()
        
        if(passwordTextField.text == "") {
            let ac = UIAlertController(title: NSLocalizedString("PasswordNotSet", comment: "Password not set"), message: NSLocalizedString("PleaseEnterPassword", comment: "Please enter the password.") , preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
            self.viewController?.presentViewController(ac, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func validateEmail(emailTextField: TextFieldValidator) -> Bool {
        if(!emailTextField.validate()) {
            emailTextField.tapOnError()
            return false
        }
        emailTextField.resignFirstResponder()
        if(emailTextField.text == "") {
            let ac = UIAlertController(title: NSLocalizedString("EmailNotSet", comment: "Email not set") , message: NSLocalizedString("PleaseEnterTheEmail", comment: "Please enter the email."), preferredStyle: UIAlertControllerStyle.Alert)
            self.viewController?.presentViewController(ac, animated: true, completion: nil)
            return false
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
                        SHOauthToken.goToDiscover()
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
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("LoginError", comment: "Could not log you in, please try again!"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
        self.viewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
}
