//
//  MessageAttachmentPhotoBrowserViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MessageAttachmentPhotoBrowserViewController: PhotoBrowser {
    
    var viewModel: MessageAttachmentPhotoBrowserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
    }
}
