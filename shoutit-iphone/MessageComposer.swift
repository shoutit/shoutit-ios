//
//  messageComposer.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 29/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import MessageUI
import ShoutitKit

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController(_ phoneNumber: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = [phoneNumber]
        messageComposeVC.body = Constants.Invite.inviteText
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
