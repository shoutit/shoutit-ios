//
//  ModalNavigationController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.navigationBar.barTintColor = UIColor(shoutitColor: .PrimaryGreen)
        self.navigationBar.tintColor = UIColor.whiteColor()
    }
}

extension ModalNavigationController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.prefersNavigationBarHidden(), animated: animated)
        
        if viewController !== self.viewControllers[0] {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.backButton(), style: .Plain, target: viewController, action: "pop")
        }
    }
}
