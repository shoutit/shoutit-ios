//
//  SHNavigationViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHNavigationViewController: UINavigationController, UINavigationControllerDelegate {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 1 {
            viewController.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "backThin"), style: .Plain, target: viewController, action: "pop"), UIBarButtonItem(image: UIImage(named: "navMenu"), style: .Plain, target: viewController, action: "toggleMenu")]
        } else {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navMenu"), style: .Plain, target: viewController, action: "toggleMenu")
        }
    }
    
}
