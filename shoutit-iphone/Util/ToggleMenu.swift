//
//  File.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func toggleMenu() {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.ToggleMenuNotification, object: nil, userInfo: nil)
    }
    
    @IBAction func pop() {
        if let navigationController = self.navigationController {
            navigationController.popViewControllerAnimated(true)
        }
    }
}