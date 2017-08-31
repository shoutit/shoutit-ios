//
//  ConversationAttachmentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationAttachmentViewController: UIViewController {

    var completion: ((_ type: PickerAttachmentType) -> Void)!
    
    @IBAction func mediaAction() {
        dismissWithType(.media)
    }
    
    @IBAction func shoutAction() {
        dismissWithType(.shout)
    }
    
    @IBAction func locationAction() {
        dismissWithType(.location)
    }
    
    @IBAction func profileAction() {
        dismissWithType(.profile)
    }
    
    fileprivate func dismissWithType(_ type: PickerAttachmentType) {
        self.dismiss(animated: true) { 
            self.completion(type)
        }
    }
    
    @IBAction override func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
