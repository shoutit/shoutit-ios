//
//  SHLoginPopupViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/14/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHLoginPopupViewController: BaseViewController, GIDSignInUIDelegate {

    private var viewModel: SHLoginPopupViewModel?
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var isFromCreateShout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tapGesture
        self.addTapGesture()
        
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
    
    override func initializeViewModel() {
        viewModel = SHLoginPopupViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.54)
        if(isFromCreateShout) {
            self.titleLabel.text = "Login to create shout"
        }
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
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        viewModel?.loginWithFacebook()
    }
    
    @IBAction func loginWithGoogle(sender: AnyObject) {
        viewModel?.loginWithGplus()
    }
    
    
    @IBAction func signupOrLoginAction(sender: AnyObject) {
        let destinationVC = UIStoryboard.getLogin().instantiateViewControllerWithIdentifier("SHLoginViewController")
        let navigationController = UINavigationController(rootViewController: destinationVC)
       // navigationController.navigationItem.leftBarButtonItem?.action = Selector("backToLoginPopup")
        let backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Done, target: self, action: Selector("backToLoginPopup"))
        destinationVC.navigationItem.leftBarButtonItem = backButton
        destinationVC.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
       // navigationController.navigationItem.leftBarButtonItem = backButton
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func backToLoginPopup () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addTapGesture () {
        let gesture = UITapGestureRecognizer(target: self, action: "gotoLogin")
        parentView.addGestureRecognizer(gesture)
    }
    
    func gotoLogin () {
        SHOauthToken.goToLogin(self)
    }
    
    deinit {
        viewModel?.destroy()
    }

}
