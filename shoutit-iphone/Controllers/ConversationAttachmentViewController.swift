//
//  ConversationAttachmentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationAttachmentViewController: UIViewController {

    var completion: ((type: MessageAttachmentType) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func photoAction() {
        dismissWithType(MessageAttachmentType.Image)
    }
    
    @IBAction func shoutAction() {
        dismissWithType(MessageAttachmentType.Shout)
    }
    
    @IBAction func locationAction() {
        dismissWithType(MessageAttachmentType.Location)
    }
    
    @IBAction func videoAction() {
        dismissWithType(MessageAttachmentType.Video)
    }
    
    private func dismissWithType(type: MessageAttachmentType) {
        self.dismissViewControllerAnimated(true) { 
            self.completion(type: type)
        }
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
