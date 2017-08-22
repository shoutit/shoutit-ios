//
//  ModalNavigationController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ModalNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        self.navigationBar.tintColor = UIColor.white
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension ModalNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
        
        if viewController !== self.viewControllers[0] {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .plain, target: viewController, action: #selector(UIViewController.pop))
        }
    }
}
