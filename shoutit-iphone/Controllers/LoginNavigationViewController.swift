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
        navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginNavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
    }
}
