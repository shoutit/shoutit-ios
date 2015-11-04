//
//  SHLoginViewModel.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLoginViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource {

    var viewController: SHLoginViewController
    
    var isSignIn = Bool()
    var signArray = [[String: AnyObject]]()
    private let webViewController = SHModalWebViewController()
    
    required init(viewController: SHLoginViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.isSignIn = true
        self.setupLogin()
        self.setupText()
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
    func performLogin() {
        if validateAuthentication() {
            // Perform API Request
            if (self.isSignIn) {
                // Perform Sign In
            } else {
                // Perform SignUp
            }
        }
        
        if (self.isSignIn) {
        }
        
        //        if(self.isSignIn)
        //        {
        //            self.
        //
        //            [self.loginModel signInWithShout:emailTextField.text pass:passwordTextField.text];
        //            [self.view addSubview:self.greenView];
        //            [SVProgressHUD showWithStatus:NSLocalizedString(@"Signing In..." , @"Signing In..." ) maskType:SVProgressHUDMaskTypeBlack];
        //
        //        }else{
        //            if(![nameTextField validate])
        //            {
        //                [nameTextField tapOnError];
        //                return;
        //            }
        //            [nameTextField resignFirstResponder];
        //            if ([nameTextField.text  isEqual:  @""])
        //            {
        //                [UIAlertView showAlertWithTitle:NSLocalizedString(@"Name not set", @"Name not set") message:NSLocalizedString(@"Please enter the name.", @"Please enter the name.")];
        //                return;
        //            }
        //            [self.loginModel signUpWithShout:emailTextField.text pass:passwordTextField.text name:nameTextField.text];
        //            [self.view addSubview:self.greenView];
        //            [SVProgressHUD showWithStatus:NSLocalizedString(@"Signing In...", @"Signing In...") maskType:SVProgressHUDMaskTypeBlack];
        //            
        //        }
    }
    
    func switchSignIn() {
        if self.isSignIn == true {
            return
        }
        self.viewController.signUpButton.layer.borderWidth = 0
        self.viewController.signInButton.layer.borderWidth = 1
        self.isSignIn = true
        self.viewController.tableView.beginUpdates()
        self.viewController.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.viewController.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: {self.viewController.shoutSignInButton.titleLabel!.alpha = 0},
            completion: {(finished: Bool) in self.viewController.shoutSignInButton.setTitle(NSLocalizedString("Sign In",comment: "Sign In"), forState: UIControlState.Normal)
                UIView.animateWithDuration(0.1, animations: {self.viewController.shoutSignInButton.titleLabel!.alpha = 1})
        })
    }
    
    func switchSignUp() {
        if self.isSignIn == false {
            return
        }
        self.viewController.signInButton.layer.borderWidth = 0
        self.viewController.signUpButton.layer.borderWidth = 1
        self.isSignIn = false
        self.viewController.tableView.beginUpdates()
        self.viewController.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.viewController.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: {self.viewController.shoutSignInButton.titleLabel!.alpha = 0},
            completion: {(finished: Bool) in self.viewController.shoutSignInButton.setTitle(NSLocalizedString("Create Account",comment: "Create Account"), forState: UIControlState.Normal)
                UIView.animateWithDuration(0.1, animations: {self.viewController.shoutSignInButton.titleLabel!.alpha = 1})
        })
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
    
    // MARK - UITableView Delegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SHLoginInputCell", forIndexPath: indexPath)
        let textView = cell.viewWithTag(100) as! TextFieldValidator
        textView.presentInView = tableView.window
        let dict = self.signArray[indexPath.row]
        textView.text = dict["text"]?.stringValue
        textView.placeholder = dict["placeholder"]?.stringValue
        textView.addTarget(self, action: NSSelectorFromString(dict["selector"]! as! String), forControlEvents: UIControlEvents.EditingChanged)
        textView.addTarget(self, action: NSSelectorFromString(dict["selectorBegin"]! as! String), forControlEvents: UIControlEvents.EditingDidBegin)
        textView.isMandatory = true
        
        switch (indexPath.row) {
        case 0:
            self.signArray[indexPath.row]["emailTextField"] = textView
            textView.addRegx(Constants.RegEx.REGEX_EMAIL, withMsg: "Enter valid email.") // Todo Localization
        case 1:
            self.signArray[indexPath.row]["passwordTextField"] = textView
            textView.addRegx(Constants.RegEx.REGEX_PASSWORD_LIMIT, withMsg: "Password charaters limit should be come between 6-20") // Todo Localization
            textView.secureTextEntry = true
        case 2:
            self.signArray[indexPath.row]["nameTextField"] = textView
        default:
            break;
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSignIn ? 2 : 3
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
        self.viewController.termsAndConditionsTextView.attributedText = text
        self.viewController.termsAndConditionsTextView.editable = false
        self.viewController.termsAndConditionsTextView.delaysContentTouches = false
    }
    
    private func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
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
    
    private func textEditBegin(textField: UITextField, row: Int) {
        self.viewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
    }
    
    private func textFieldChanged(textField: TextFieldValidator, row: Int) {
        self.signArray[row]["text"] = textField.text
        textField.validate()
    }
    
    private func validateAuthentication() -> Bool {
        if let emailTextField = self.signArray[0]["emailTextField"] as? TextFieldValidator {
            if(!emailTextField.validate()) {
                //                emailTextField.tapOnError()
                return false
            }
            emailTextField.resignFirstResponder()
            if(emailTextField.text == "") {
                let ac = UIAlertController(title: "Email not set", message: "Please enter the email.", preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
            }
        }
        if let passwordTextField = self.signArray[1]["passwordTextField"] as? TextFieldValidator {
            if(!passwordTextField.validate()) {
                // passwordTextField.tapOnError()
                return false
            }
            passwordTextField.resignFirstResponder()
            
            if(passwordTextField.text == "") {
                let ac = UIAlertController(title: "Password not set", message: "Please enter the password.", preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
            }
        }
        if self.isSignIn, let nameTextField = self.signArray[2]["nameTextField"] as? TextFieldValidator {
            if(!nameTextField.validate()) {
                // nameTextField.tapOnError()
                return false
            }
            nameTextField.resignFirstResponder()
            
            if(nameTextField.text == "") {
                let ac = UIAlertController(
                    title: NSLocalizedString("Name not set", comment: "Name not set"),
                    message: NSLocalizedString("Please enter the name.", comment: "Please enter the name."),
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                self.viewController.presentViewController(ac, animated: true, completion: nil)
                return false
            }
            
        }
        return true
    }
    
}
