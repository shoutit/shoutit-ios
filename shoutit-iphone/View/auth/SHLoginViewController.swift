//
//  SHLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SHLoginViewController: BaseTableViewController, GIDSignInUIDelegate {

    @IBOutlet weak var shoutSignInButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    private var viewModel: SHLoginViewModel?
    var isSignIn = Bool()
    var signArray = [[String: AnyObject]]()
    private var activeRow: Int!
    private var greenView: UIView!
    private let webViewController = SHModalWebViewController()
    
    func setupLogin() {
        self.signArray = [
            ["placeholder": "E-mail", "text": "", "selector": "emailChanged:", "selectorBegin": "emailBegin:"],
            ["placeholder": "Password", "text": "", "selector": "passwordChanged:", "selectorBegin":"passwordBegin:"],
            ["placeholder": "Name", "text": "", "selector": "nameChanged:", "selectorBegin": "nameBegin:"]]
    }
    
    func setupText() {
        let text = NSMutableAttributedString(attributedString: self.textView.attributedText)
        text.addAttribute(NSLinkAttributeName, value: "initial://terms", range: (text.string as NSString).rangeOfString("Shout IT Terms"))
        text.addAttribute(NSLinkAttributeName, value: "initial://privacy", range: (text.string as NSString).rangeOfString("Privacy Policy"))
        text.addAttribute(NSLinkAttributeName, value: "initial://rules", range: (text.string as NSString).rangeOfString("Marketplace Rules"))
        self.textView.attributedText = text
        self.textView.editable = false
        self.textView.delaysContentTouches = false
    }
    
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        if(url.scheme == "initial") {
            if(url.absoluteString.containsString("terms")) {
                webViewController.presentFromViewController(self, withHTMLFile: "tos")
            } else if (url.absoluteString.containsString("privacy")) {
                webViewController.presentFromViewController(self, withHTMLFile: "policy")
            } else if (url.absoluteString.containsString("rules")) {
                webViewController.presentFromViewController(self, withHTMLFile: "rules")
            }
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
        
        // Google instance
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = Constants.Google.clientID
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true;
        GIDSignIn.sharedInstance().allowsSignInWithBrowser = false;
        GIDSignIn.sharedInstance().allowsSignInWithWebView = true;
        // Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        
        
        // Setup Delegates and data Source
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
        
        self.isSignIn = true
        self.setupLogin()
        self.setupText()
        self.shoutSignInButton.setTitle("Sign In", forState: UIControlState.Normal) // Todo Localization
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.shoutSignInButton.layer.cornerRadius = 0.5
        self.signInButton.layer.cornerRadius = 5
        self.signUpButton.layer.cornerRadius = 5
        self.signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.signInButton.layer.borderWidth = 1
        
    }
    
    override func initializeViewModel() {
        viewModel = SHLoginViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize: CGSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        var contentInsets: UIEdgeInsets
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
        } else {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0)
        }
        let rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        UIView.animateWithDuration((rate?.doubleValue)!, animations: {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.activeRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let rate = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]
        UIView.animateWithDuration((rate?.doubleValue)!, animations: {
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
            
        })
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLoginAction(sender: AnyObject) {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if (error != nil) {
                log.info("Process error")
            } else {
                if result.isCancelled {
                    log.info("Cancelled")
                } else {
                    log.info("Logged in")
                }
            }
        }
        
    }
    
    @IBAction func googleLoginAction(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func resetPasswordAction(sender: AnyObject) {

    }
    
    @IBAction func shoutitLoginAction(sender: AnyObject) {
        let emailTextField = self.signArray[0]["emailTextField"] as! TextFieldValidator
        let passwordTextField = self.signArray[0]["passwordTextField"] as! TextFieldValidator
        let nameTextField = self.signArray[0]["nameTextField"] as! TextFieldValidator
        
        if(!emailTextField.validate()) {
           // emailTextField.tapOnError()
            return
        }
        emailTextField.resignFirstResponder()
        if(emailTextField.text == "") {
            let ac = UIAlertController(title: "Email not set", message: "Please enter the email.", preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
            self.presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        if(!passwordTextField.validate()) {
           // passwordTextField.tapOnError()
            return
        }
        passwordTextField.resignFirstResponder()
        
        if(passwordTextField.text == "") {
            let ac = UIAlertController(title: "Password not set", message: "Please enter the password.", preferredStyle: UIAlertControllerStyle.Alert) // Todo Localization
            self.presentViewController(ac, animated: true, completion: nil)
            return
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
    
    @IBAction func signInSwitchAction(sender: AnyObject) {
        if self.isSignIn == true {
            return
        }
        self.signUpButton.layer.borderWidth = 0
        self.signInButton.layer.borderWidth = 1
        self.isSignIn = true
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: {    self.shoutSignInButton.titleLabel!.alpha = 0},
            completion: {(finished: Bool) in self.shoutSignInButton.setTitle(NSLocalizedString("Sign In",comment: "Sign In"), forState: UIControlState.Normal)
                UIView.animateWithDuration(0.1, animations: {self.shoutSignInButton.titleLabel!.alpha = 1})
        })
    }
    
    @IBAction func signUpSwitchAction(sender: AnyObject) {
        if self.isSignIn == false {
            return
        }
        self.signInButton.layer.borderWidth = 0
        self.signUpButton.layer.borderWidth = 1
        self.isSignIn = false
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
        UIView.animateWithDuration(0.1, animations: {    self.shoutSignInButton.titleLabel!.alpha = 0},
            completion: {(finished: Bool) in self.shoutSignInButton.setTitle(NSLocalizedString("Create Account",comment: "Create Account"), forState: UIControlState.Normal)
                UIView.animateWithDuration(0.1, animations: {self.shoutSignInButton.titleLabel!.alpha = 1})
        })
    }
    
    func showGreenView(show: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if show {
            self.view.addSubview(self.greenView)
            } else {
                self.greenView.removeFromSuperview()
            }
        })
    }
    
    
    @IBAction func skipLogin(sender: AnyObject) {
        
    }
    
    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    // UIViewController.
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
       // myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // SignOut from Google
//    @IBAction func didTapSignOut(sender: AnyObject) {
//        GIDSignIn.sharedInstance().signOut()
//    }
       
    
    func emailBegin(theTextField: UITextField) {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        self.activeRow = 0
    }
    
    func passwordBegin(theTextField: UITextField) {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        self.activeRow = 1
    }
    
    func nameBegin(theTextField: UITextField) {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        self.activeRow = 2
    }
    
    func emailChanged(theTextField: TextFieldValidator) {
        self.signArray[0]["text"] = theTextField.text
        theTextField.validate()
    }
    
    func passwordChanged(theTextField: TextFieldValidator) {
        self.signArray[1]["text"] = theTextField.text
        theTextField.validate()
    }
    
    func nameChanged(theTextField: TextFieldValidator) {
        self.signArray[2]["text"] = theTextField.text
        theTextField.validate()
    }
    
    
    deinit {
        viewModel?.destroy()
    }
}
