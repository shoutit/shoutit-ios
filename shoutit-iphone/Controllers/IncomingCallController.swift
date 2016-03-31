//
//  IncomingCallController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class IncomingCallController: UIViewController {

    var invitation : TWCIncomingInvite!
    
    @IBOutlet weak var incomingCallLabel: UILabel!
    
    var answerHandler : ((invitation: TWCIncomingInvite) -> Void)?
    var discardHandler : ((invitation: TWCIncomingInvite) -> Void)?

    @IBAction func discardAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            if let discardHandler = self.discardHandler {
                discardHandler(invitation: self.invitation)
            }
        }
        
    }
    
    @IBAction func answerAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            if let answerHandler = self.answerHandler {
                answerHandler(invitation: self.invitation)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.incomingCallLabel.text = NSLocalizedString("Incoming Call from ", comment: "") + "\(invitation.from)"
    }
}
