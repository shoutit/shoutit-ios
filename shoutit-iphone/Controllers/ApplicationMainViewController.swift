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
    var containerView: UIView! {
        return view
    }
    
    private(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Account.sharedInstance.isUserLoggedIn {
            showLogin()
        }
    }
    
    private func showLogin() {
        let navigationController = UINavigationController()
        let loginFlow = LoginFlowController(navigationController: navigationController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
