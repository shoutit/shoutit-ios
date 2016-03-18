//
//  SHNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHNavigationViewController: UINavigationController, UINavigationControllerDelegate {
    
    var willShowViewControllerPreferringTabBarHidden: (Bool -> Void)?
    var ignoreToggleMenu : Bool = false

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        willShowViewControllerPreferringTabBarHidden?(viewController.prefersTabbarHidden())
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
        
        if ignoreToggleMenu {
            return
        }
        
        if self.viewControllers.count > 1 {
            viewController.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage.backButton(), style: .Plain, target: viewController, action: "pop"), UIBarButtonItem(image: UIImage.menuHamburger(), style: .Plain, target: viewController, action: "toggleMenu")]
        } else {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.menuHamburger(), style: .Plain, target: viewController, action: "toggleMenu")
        }
    }
    
}
