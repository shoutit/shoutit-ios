//
//  SignupViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Material

final class SignupViewController: UIViewController {
    
    // UI
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var signupButton: CustomUIButton!
    @IBOutlet weak var termsAndPolicyLabel: UILabel!
    @IBOutlet weak var switchToLoginLabel: UILabel!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
    }
}