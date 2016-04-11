//
//  IncomingCallController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class IncomingCallController: UIViewController {

    var invitation : TWCIncomingInvite! {
        didSet {
            fetchCallingProfile()
        }
    }
    
    private let disposeBag = DisposeBag()
    
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
        
        self.incomingCallLabel.text = NSLocalizedString("Incoming Call", comment: "")
    }
    
    func fetchCallingProfile() {
        APIProfileService.retrieveProfileWithTwilioUsername(invitation.from).subscribeNext { [weak self] (profile) in
            self?.incomingCallLabel.text = NSLocalizedString("Incoming Call from ", comment: "") + "\(profile.username)"
        }.addDisposableTo(disposeBag)
    }
}
