//
//  CreateShoutPopupViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 09.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class CreateShoutPopupViewController: UIViewController {

    var selectedType: ShoutType?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createShoutController = segue.destination as? CreateShoutParentViewController {
            createShoutController.type = selectedType
        }
    }

    @IBAction func createOffer() {
        selectedType = .Offer
        self.performSegue(withIdentifier: "createShoutSegue", sender: nil)
    }
    
    @IBAction func createRequest() {
        selectedType = .Request
        self.performSegue(withIdentifier: "createShoutSegue", sender: nil)
    }
}

extension CreateShoutPopupViewController {
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}
