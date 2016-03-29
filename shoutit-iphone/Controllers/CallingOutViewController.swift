//
//  CallingOutViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CallingOutViewController: UIViewController {

    var callingToProfile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Twilio.sharedInstance.sendInvitationTo(callingToProfile) { [weak self] (conversation, error) in
            if let error = error {
                self?.showError(error)
                return
            }
            
            print("connected")
        }
    }

    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    func showError(error: NSError) {
        let alert = UIAlertController(title: NSLocalizedString("Could not establish connection right now.", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
