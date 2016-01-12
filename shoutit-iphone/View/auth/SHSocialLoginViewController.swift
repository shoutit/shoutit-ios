//
//  SHSocialLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 18/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHSocialLoginViewController: BaseViewController, GIDSignInUIDelegate {

    private var viewModel: SHLoginViewModel?
    @IBOutlet weak var topSpaceJoinNowConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceSignUpConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar"))
        
        // Google instance
        GIDSignIn.sharedInstance().clientID = Constants.Google.clientID
        GIDSignIn.sharedInstance().serverClientID = Constants.Google.serverClientID
        GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().allowsSignInWithWebView = true
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/userinfo.email"]
        
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        topSpaceJoinNowConstraint.constant = UIScreen.mainScreen().bounds.height / 7
        bottomSpaceSignUpConstraint.constant = UIScreen.mainScreen().bounds.height / 10
    }
    
    override func initializeViewModel() {
        self.viewModel = SHLoginViewModel(socialViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func loginGooglePlus(sender: AnyObject) {
        viewModel?.loginWithGplus()
    }
    
    @IBAction func loginFacebook(sender: AnyObject) {
        viewModel?.loginWithFacebook()
    }
    
    @IBAction func showFeedback(sender: AnyObject) {
        viewModel?.showUserVoice(self)
    }
    
    @IBAction func showTerms(sender: AnyObject) {
        self.viewModel?.showTerms(self)
    }
    // MARK - GIDSignInUIDelegate
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
}
