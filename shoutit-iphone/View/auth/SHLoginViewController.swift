//
//  SHLoginViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHLoginViewController: BaseViewController {

    @IBOutlet weak var termsAndConditionsTextView: UITextView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var signUpEmailOrUsername: TextFieldValidator!
    @IBOutlet weak var signInEmailOrUsername: TextFieldValidator!
    @IBOutlet weak var signUpPassword: TextFieldValidator!
    @IBOutlet weak var signInPassword: TextFieldValidator!
    @IBOutlet weak var firstname: TextFieldValidator!
    @IBOutlet weak var lastname: TextFieldValidator!
    
    private var viewModel: SHLoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func resetPasswordAction(sender: AnyObject) {
        viewModel?.resetPassword()
    }
    
    @IBAction func shoutitLoginAction(sender: AnyObject) {
        viewModel?.performLogin()
    }
    
    @IBAction func shoutitSignUpAction(sender: AnyObject) {
        viewModel?.performSignUp()
    }
    
    @IBAction func viewChanged(sender: UISegmentedControl) {
        self.loginView.hidden = sender.selectedSegmentIndex != 0
        self.signUpView.hidden = sender.selectedSegmentIndex == 0
    }
    // SignOut from Google
//    @IBAction func didTapSignOut(sender: AnyObject) {
//        GIDSignIn.sharedInstance().signOut()
//    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showFeedback(sender: AnyObject) {
        viewModel?.showUserVoice(self)
    }
    
    @IBAction func showHelp(sender: AnyObject) {
    }
    
    @IBAction func showTerms(sender: AnyObject) {
        viewModel?.showTerms(self)
    }
    
    @IBAction func showAbout(sender: AnyObject) {
    }
    
    @IBAction func showPassword(sender: AnyObject) {
        viewModel?.togglePassword()
    }
    
    deinit {
        viewModel?.destroy()
    }
}
