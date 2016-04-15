//
//  LoginNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LoginNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return topViewController
    }
}

extension LoginNavigationViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
    }
}
