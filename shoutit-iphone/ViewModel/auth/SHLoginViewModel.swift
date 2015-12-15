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

class SHLoginViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, GIDSignInDelegate, UITextViewDelegate {

    private var viewController: SHLoginViewController
    private var isSignIn = Bool()
    private var signArray = [[String: AnyObject]]()
    private let webViewController = SHModalWebViewController()
    private let shApiAuthService = SHApiAuthService()
   
    required init(viewController: SHLoginViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.isSignIn = true
        self.setupLogin()
        self.setupText()
        
        self.viewController.termsAndConditionsTextView.delegate = self
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
                log.info("Process error")
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
    
    func performLogin() {
        if validateAuthentication() {
            // Perform API Request
            if (self.isSignIn) {
                // Perform Sign In
                if let email = self.signArray[0]["text"] as? String, let password = self.signArray[1]["text"] as? String {
                    let params = self.shApiAuthService.getLoginParams(email, password: password)
                    self.getOauthResponse(params)
                }
            } else {
                // Perform SignUp
                if let email = self.signArray[0]["text"] as? String, let password = self.signArray[1]["text"] as? String, let name = self.signArray[2]["text"] as? String {
                    let params = self.shApiAuthService.getSignUpParams(email, password: password, name: name)
                    self.getOauthResponse(params)
                }
            }
        } else {
            log.debug("Incorrect Email or Password")
        }
    }
    
    func switchSignIn() {
        if self.isSignIn {
            return
        }
        self.viewController.signUpButton.layer.borderWidth = 0
        self.viewController.signInButton.layer.borderWidth = 1
        self.isSignIn = true
        self.viewController.tableView.beginUpdates()
        self.viewController.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.viewController.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.viewController.shoutSignInButton.titleLabel?.alpha = 0
        }) { (finished) -> Void in
            self.viewController.shoutSignInButton.setTitle(NSLocalizedString("SignIn",comment: "Sign In"), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.viewController.shoutSignInButton.titleLabel?.alpha = 1
            })
        }
    }
    
    func switchSignUp() {
        if !self.isSignIn {
            return
        }
        self.viewController.signInButton.layer.borderWidth = 0
        self.viewController.signUpButton.layer.borderWidth = 1
        self.isSignIn = false
        self.viewController.tableView.beginUpdates()
        self.viewController.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.viewController.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.viewController.shoutSignInButton.titleLabel?.alpha = 0
        }) { (finished) -> Void in
            self.viewController.shoutSignInButton.setTitle(NSLocalizedString("CreateAccount",comment: "Create Account"), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.viewController.shoutSignInButton.titleLabel?.alpha = 1
            })
        }
    }
    
    func resetPassword() {
        if let emailTextField = self.signArray[0]["emailTextField"] as? TextFieldValidator {
            if(!emailTextField.validate()) {
                emailTextField.tapOnError()
                return
            }
            emailTextField.resignFirstResponder()
            if(emailTextField.text == "") {
                let ac = UIAlertController(title: NSLocalizedString("EmailNotSet", comment: "Email not set") , message: NSLocalizedString("PleaseEnterTheEmail", comment: "Please enter the email."), preferredStyle: UIAlertControllerStyle.Alert)
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return
            }
            shApiAuthService.resetPassword(emailTextField.text!, completionHandler: { (response) -> Void in
                if response.result.isSuccess {
                    let ac = UIAlertController(title: NSLocalizedString("Success", comment: "Success"), message: NSLocalizedString("Password recovery email will be sent soon.", comment: "Password recovery email will be sent soon."), preferredStyle: UIAlertControllerStyle.Alert)
                    ac.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
                    self.viewController.presentViewController(ac, animated: true, completion: nil)
                } else {
                    log.debug("Error sending the mail")
                }
            })
        }
    }
    
    func skipLogin () {
        let tabViewController = SHTabViewController()
        self.viewController.navigationController?.pushViewController(tabViewController, animated: true)
    }
    
    // MARK - Selectors
    func emailBegin(textField: UITextField) {
        textEditBegin(textField, row: 0)
    }
    
    func passwordBegin(textField: UITextField) {
        textEditBegin(textField, row: 1)
    }
    
    func nameBegin(textField: UITextField) {
        textEditBegin(textField, row: 2)
    }
    
    func emailChanged(textField: TextFieldValidator) {
        textFieldChanged(textField, row: 0)
    }
    
    func passwordChanged(textField: TextFieldValidator) {
        textFieldChanged(textField, row: 1)
    }
    
    func nameChanged(textField: TextFieldValidator) {
        textFieldChanged(textField, row: 2)
    }
    
    // TODO We still need to refactor this
    // MARK - UITableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHLoginInputCell, forIndexPath: indexPath) as! SHLoginInputTableViewCell
        cell.textField.presentInView = tableView.window
        let dict = self.signArray[indexPath.row]
        cell.textField.text = dict["text"] as? String
        cell.textField.placeholder = dict["placeholder"] as? String
        cell.textField.addTarget(self, action: NSSelectorFromString(dict["selector"]! as! String), forControlEvents: UIControlEvents.EditingChanged)
        cell.textField.addTarget(self, action: NSSelectorFromString(dict["selectorBegin"]! as! String), forControlEvents: UIControlEvents.EditingDidBegin)
        cell.textField.isMandatory = true
        
        switch (indexPath.row) {
        case 0:
            self.signArray[indexPath.row]["emailTextField"] = cell.textField
            cell.textField.addRegx(Constants.RegEx.REGEX_EMAIL, withMsg: NSLocalizedString("EnterValidMail", comment: "Enter valid email."))
        case 1:
            self.signArray[indexPath.row]["passwordTextField"] = cell.textField
            cell.textField.addRegx(Constants.RegEx.REGEX_PASSWORD_LIMIT, withMsg: NSLocalizedString("PasswordValidationError", comment: "Password charaters limit should be come between 6-20"))
            cell.textField.secureTextEntry = true
        case 2:
            self.signArray[indexPath.row]["nameTextField"] = cell.textField
        default:
            break;
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSignIn ? 2 : 3
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
        if(url.scheme == "initial") {
            if(url.absoluteString.containsString("terms")) {
                webViewController.presentFromViewController(self.viewController, withHTMLFile: "tos")
            } else if (url.absoluteString.containsString("privacy")) {
                webViewController.presentFromViewController(self.viewController, withHTMLFile: "policy")
            } else if (url.absoluteString.containsString("rules")) {
                webViewController.presentFromViewController(self.viewController, withHTMLFile: "rules")
            }
            return false
        }
        return true
    }
    
    func textEditBegin(textField: UITextField, row: Int) {
        self.viewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    func textFieldChanged(textField: TextFieldValidator, row: Int) {
        self.signArray[row]["text"] = textField.text
        textField.validate()
    }
    
    // MARK - Private
    private func setupLogin() {
        self.signArray = [
            ["placeholder": "E-mail", "text": "", "selector": "emailChanged:", "selectorBegin": "emailBegin:"],
            ["placeholder": "Password", "text": "", "selector": "passwordChanged:", "selectorBegin":"passwordBegin:"],
            ["placeholder": "Name", "text": "", "selector": "nameChanged:", "selectorBegin": "nameBegin:"]]
    }
    
    private func setupText() {
        let text = NSMutableAttributedString(attributedString: self.viewController.termsAndConditionsTextView.attributedText)
        text.addAttribute(NSLinkAttributeName, value: "initial://terms", range: (text.string as NSString).rangeOfString("Shout IT Terms"))
        text.addAttribute(NSLinkAttributeName, value: "initial://privacy", range: (text.string as NSString).rangeOfString("Privacy Policy"))
        text.addAttribute(NSLinkAttributeName, value: "initial://rules", range: (text.string as NSString).rangeOfString("Marketplace Rules"))
        self.viewController.termsAndConditionsTextView.editable = false
        self.viewController.termsAndConditionsTextView.delaysContentTouches = false
        self.viewController.termsAndConditionsTextView.attributedText = text
    }
    
    private func validateAuthentication() -> Bool {
        if let emailTextField = self.signArray[0]["emailTextField"] as? TextFieldValidator {
            if(!emailTextField.validate()) {
                emailTextField.tapOnError()
                return false
            }
            emailTextField.resignFirstResponder()
            if(emailTextField.text == "") {
                let ac = UIAlertController(title: NSLocalizedString("EmailNotSet", comment: "Email not set") , message: NSLocalizedString("PleaseEnterTheEmail", comment: "Please enter the email."), preferredStyle: UIAlertControllerStyle.Alert)
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
            }
        }
        if let passwordTextField = self.signArray[1]["passwordTextField"] as? TextFieldValidator {
            if(!passwordTextField.validate()) {
                passwordTextField.tapOnError()
                return false
            }
            passwordTextField.resignFirstResponder()
            
            if(passwordTextField.text == "") {
                let ac = UIAlertController(title: NSLocalizedString("PasswordNotSet", comment: "Password not set"), message: NSLocalizedString("PleaseEnterPassword", comment: "Please enter the password.") , preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
            }
        }
        if !self.isSignIn, let nameTextField = self.signArray[2]["nameTextField"] as? TextFieldValidator {
            if(!nameTextField.validate()) {
                nameTextField.tapOnError()
                return false
            }
            nameTextField.resignFirstResponder()
            
            if(nameTextField.text == "") {
                let ac = UIAlertController(
                    title: NSLocalizedString("NameNotSet", comment: "Name not set"),
                    message: NSLocalizedString("PleaseEnterName", comment: "Please enter the name."),
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
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
                        let tabViewController = SHTabViewController()
                        tabViewController.selectedIndex = 1
                        self.viewController.navigationController?.pushViewController(tabViewController, animated: true)
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
        self.viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
}
