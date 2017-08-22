//
//  SHNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

final class SHNavigationViewController: UINavigationController, UINavigationControllerDelegate {
    
    var willShowViewControllerPreferringTabBarHidden: ((Bool) -> Void)?
    var ignoreToggleMenu : Bool = false
    var ignoreTabbarAppearance : Bool = false

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor(shoutitColor: .primaryGreen)
        navigationBar.tintColor = UIColor.white
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if topViewController is SearchViewController {
            return .default
        }
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return nil
    }
    
    func adjustTabBarControllerForTopViewController() {
        guard let topViewController = topViewController else { return }
        willShowViewControllerPreferringTabBarHidden?(topViewController.prefersTabbarHidden())
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        willShowViewControllerPreferringTabBarHidden?(viewController.prefersTabbarHidden())
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
        
        if ignoreToggleMenu || viewController.ignoresToggleMenu() {
            return
        }
        
        let toggleMenuBarButtonItem = UIBarButtonItem(image: UIImage.menuHamburger(), style: .plain, target: viewController, action: #selector(UIViewController.toggleMenu))
        let backBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .plain, target: viewController, action: #selector(UIViewController.pop))
        
        if viewControllers.count > 1 {
            if viewController.prefersMenuHamburgerHidden() {
                viewController.navigationItem.leftBarButtonItem = backBarButtonItem
            } else {
                viewController.navigationItem.leftBarButtonItems = [backBarButtonItem, toggleMenuBarButtonItem]
            }
        } else {
            viewController.navigationItem.leftBarButtonItem = toggleMenuBarButtonItem
        }
    }
}
