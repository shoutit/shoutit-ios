//
//  ApplicationMainViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ApplicationMainViewControllerRootObject: class {
    
}

final class ApplicationMainViewController: UIViewController {
    
    // consts
    let animationDuration: Double = 0.25
    
    private let disposeBag = DisposeBag()
    
    private var loginFlowController: LoginFlowController?
    private(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
 
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLogin), name: Constants.Notification.UserDidLogoutNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notification.UserDidLogoutNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Account.sharedInstance.isUserAuthenticated {
            _ = try? Account.sharedInstance.clearUserData()
            showLogin()
        }
    }
    
    // MARK: - Navigation
    
    @objc private func showLogin() {
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Status bar
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return childViewControllers.first
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
