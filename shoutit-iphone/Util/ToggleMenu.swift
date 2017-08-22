//
//  File.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

extension UIViewController {
    
    @IBAction func toggleMenu() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notification.ToggleMenuNotification), object: nil, userInfo: nil)
    }
    
    @IBAction func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
