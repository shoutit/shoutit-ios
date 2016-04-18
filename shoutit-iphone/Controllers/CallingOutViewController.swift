//
//  CallingOutViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 29/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol CallingOutViewControllerFlowDelegate: class, ChatDisplayable {}

final class CallingOutViewController: UIViewController {

    weak var flowDelegate: CallingOutViewControllerFlowDelegate?
    
    var callingToProfile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let localMedia = TWCLocalMedia()
        
        Twilio.sharedInstance.sendInvitationTo(callingToProfile, media: localMedia) { [weak self] (conversation, error) in
            if let error = error {
                self?.showError(error)
                return
            }
            
            if let conversation = conversation {
                let controller = Wireframe.videoCallController()
                
                controller.conversation = conversation
                
                self?.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    func showError(error: NSError) {
        let alert = UIAlertController(title: NSLocalizedString("Could not establish connection right now.", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
