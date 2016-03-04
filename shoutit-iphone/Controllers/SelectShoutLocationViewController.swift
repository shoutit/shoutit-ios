//
//  SelectShoutLocationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import GooglePlaces

class SelectShoutLocationViewController: ChangeLocationTableViewController {

    override func finishWithAddress(address: Address) {
        if let finish = self.finishedBlock {
            finish(true, address)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }    
}
