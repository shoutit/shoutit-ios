//
//  UIViewController+Debug.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func notImplemented() {
        let alertController = UIAlertController(title: nil, message: "Action not implemented", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: LocalizedString.ok, style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
