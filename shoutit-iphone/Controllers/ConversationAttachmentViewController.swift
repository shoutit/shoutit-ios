//
//  ConversationAttachmentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationAttachmentViewController: UIViewController {

    var completion: ((type: PickerAttachmentType) -> Void)!
    
    @IBAction func mediaAction() {
        dismissWithType(.Media)
    }
    
    @IBAction func shoutAction() {
        dismissWithType(.Shout)
    }
    
    @IBAction func locationAction() {
        dismissWithType(.Location)
    }
    
    @IBAction func profileAction() {
        dismissWithType(.Profile)
    }
    
    private func dismissWithType(type: PickerAttachmentType) {
        self.dismissViewControllerAnimated(true) { 
            self.completion(type: type)
        }
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
