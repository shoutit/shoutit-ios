//
//  LoginMethodChoiceViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol LoginMethodChoiceViewControllerFlowDelegate: class, LoginHelpDisplayable {
}

final class LoginMethodChoiceViewController: UIViewController {
    
    // ui outlets
    @IBOutlet weak var loginWithFacebookButton: CustomUIButton!
    @IBOutlet weak var loginWithGoogleButton: CustomUIButton!
    @IBOutlet weak var loginWithEmailButton: CustomUIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    // view model
    var viewModel: LoginMethodChoiceViewModel!
    
    // navigation
    weak var flowDelegate: LoginMethodChoiceViewControllerFlowDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        setupRX()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        print("ZAIMPLEMENTOWANA METODA")
    }
}
