//
//  LoginViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

class LoginViewController: UIViewController {
    
    // UI
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var switchToSignupLabel: UILabel!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
    }
}
