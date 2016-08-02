//
//  UIViewController+LoggedUser.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

extension UIViewController {
    
    func checkIfUserIsLoggedInAndDisplayAlertIfNot() -> Bool {
        if Account.sharedInstance.user == nil || Account.sharedInstance.user!.isGuest {
            displayUserMustBeLoggedInAlert()
            return false
        }
        return true
    }
    
    func displayUserMustBeLoggedInAlert() {
        let error = LightError(userMessage: NSLocalizedString("You must be logged in to perform this action", comment: "Must be logged Common Message"))
        showError(error)
    }
}
