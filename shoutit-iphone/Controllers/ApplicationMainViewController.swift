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
import ShoutitKit

protocol ApplicationMainViewControllerRootObject: class {
    
}

final class ApplicationMainViewController: UIViewController {
    
    // consts
    let animationDuration: Double = 0.25
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var loginFlowController: LoginFlowController?
    fileprivate(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLogin), name: NSNotification.Name(rawValue: Constants.Notification.UserDidLogoutNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.UserDidLogoutNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Account.sharedInstance.isUserAuthenticated {
            _ = try? Account.sharedInstance.clearUserData()
            showLogin()
        }
    }
    
    // MARK: - Navigation
    
    @objc fileprivate func showLogin() {
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController)
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Status bar
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return childViewControllers.first
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
