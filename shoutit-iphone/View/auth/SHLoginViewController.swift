//
//  SHLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLoginViewController: BaseTableViewController, GIDSignInUIDelegate {

    @IBOutlet weak var shoutSignInButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsAndConditionsTextView: UITextView!
    
    private var viewModel: SHLoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.shoutSignInButton.setTitle(NSLocalizedString("SignIn", comment: "Sign In"), forState: UIControlState.Normal)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.shoutSignInButton.layer.cornerRadius = 0.5
        self.signInButton.layer.cornerRadius = 5
        self.signUpButton.layer.cornerRadius = 5
        self.signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.signInButton.layer.borderWidth = 1
        
        viewModel?.viewDidLoad()
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLoginAction(sender: AnyObject) {
        viewModel?.loginWithFacebook()
    }
    
    @IBAction func googleLoginAction(sender: AnyObject) {
        viewModel?.loginWithGplus()
    }
    
    @IBAction func resetPasswordAction(sender: AnyObject) {
        viewModel?.resetPassword()
    }
    
    @IBAction func shoutitLoginAction(sender: AnyObject) {
        viewModel?.performLogin()
    }
    
    @IBAction func signInSwitchAction(sender: AnyObject) {
        viewModel?.switchSignIn()
    }
    
    @IBAction func signUpSwitchAction(sender: AnyObject) {
        viewModel?.switchSignUp()
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
    
    
    deinit {
        viewModel?.destroy()
    }
}
