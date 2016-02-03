//
//  ApplicationMainViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ApplicationMainViewControllerRootObject: class {
    
}

final class ApplicationMainViewController: UIViewController {
    
    // consts
    let animationDuration: Double = 0.25
    
    private var loginFlowController: LoginFlowController?
    private var loginWasPresented = false
    private(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Account.sharedInstance.isUserLoggedIn && !loginWasPresented {
            loginWasPresented = true
            showLogin()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func showLogin() {
        let navigationController = UINavigationController()
        loginFlowController = LoginFlowController(navigationController: navigationController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
