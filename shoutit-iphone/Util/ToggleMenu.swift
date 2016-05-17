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
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func dismiss() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}