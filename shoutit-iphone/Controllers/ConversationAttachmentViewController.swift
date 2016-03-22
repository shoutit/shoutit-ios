//
//  ConversationAttachmentViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 22/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ConversationAttachmentType : Int {
    case Photo
    case Shout
    case Location
    case Video
}

class ConversationAttachmentViewController: UIViewController {

    var completion: ((type: ConversationAttachmentType) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func photoAction() {
        completion(type: ConversationAttachmentType.Photo)
        dismiss()
    }
    
    @IBAction func shoutAction() {
        completion(type: ConversationAttachmentType.Shout)
        dismiss()
    }
    
    @IBAction func locationAction() {
        completion(type: ConversationAttachmentType.Location)
        dismiss()
    }
    
    @IBAction func videoAction() {
        completion(type: ConversationAttachmentType.Video)
        dismiss()
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
