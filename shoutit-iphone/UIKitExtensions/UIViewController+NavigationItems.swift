//
//  UIViewController+NavigationItems.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func applyNavigationItems() {
        
        if let navigationController = self.navigationController {
            
            let leftBarButtonItem: UIBarButtonItem
            if self === navigationController.viewControllers[0] {
                leftBarButtonItem = UIBarButtonItem(image: UIImage.menuHamburger(), style: .Plain, target: self, action: #selector(UIViewController.toggleMenu))
            } else {
                leftBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .Plain, target: self, action: #selector(UIViewController.pop))
            }
            self.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
    }
    
    func applyBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .Plain, target: self, action: #selector(UIViewController.pop))
    }
}
