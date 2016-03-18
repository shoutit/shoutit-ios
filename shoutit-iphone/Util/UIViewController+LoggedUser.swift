//
//  UIViewController+LoggedUser.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func performLoggedUserRequiredAction(action:(Void -> Void)) {
        if Account.sharedInstance.user == nil || Account.sharedInstance.user!.isGuest {
            displayUserMustBeLoggedInAlert()
            return
        }
        action()
    }
    
    func validateLoggedUser() -> Bool {
        if Account.sharedInstance.user == nil || Account.sharedInstance.user!.isGuest {
            displayUserMustBeLoggedInAlert()
            return false
        }
        return true
    }
    
    func displayUserMustBeLoggedInAlert() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("You must be logged in to perform this action", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
