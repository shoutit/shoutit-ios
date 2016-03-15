//
//  CreateShoutPopupViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutPopupViewController: UIViewController {

    var selectedType: ShoutType?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let createShoutController = segue.destinationViewController as? CreateShoutParentViewController {
            createShoutController.type = selectedType
        }
    }

    @IBAction func createOffer() {
        selectedType = .Offer
        self.performSegueWithIdentifier("createShoutSegue", sender: nil)
    }
    
    @IBAction func createRequest() {
        selectedType = .Request
        self.performSegueWithIdentifier("createShoutSegue", sender: nil)
    }
}

extension CreateShoutPopupViewController {
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}
