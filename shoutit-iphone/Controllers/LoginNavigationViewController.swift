//
//  LoginNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 08/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class LoginNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension LoginNavigationViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
    }
}
