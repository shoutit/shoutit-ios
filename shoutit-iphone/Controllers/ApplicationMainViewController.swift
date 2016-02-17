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
    private var loginWasPresented = false
    private(set) weak var delegate: ApplicationMainViewControllerRootObject?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter()
            .rx_notification(Constants.Notification.UserDidLogoutNotification)
            .subscribeNext { (_) in
                self.loginWasPresented = true
                self.showLogin()
            }.addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Account.sharedInstance.isUserLoggedIn && !loginWasPresented {
            _ = try? Account.sharedInstance.logout()
            loginWasPresented = true
            showLogin()
        }
    }
    
    private func showLogin() {
        let navigationController = LoginNavigationViewController()
        loginFlowController = LoginFlowController(navigationController: navigationController)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
}
