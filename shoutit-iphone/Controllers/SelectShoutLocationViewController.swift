//
//  SelectShoutLocationViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import GooglePlaces
import ShoutitKit

final class SelectShoutLocationViewController: ChangeLocationTableViewController {

    override func finishWithAddress(address: Address) {
        if let finish = self.finishedBlock {
            finish(true, address)
        }
        
        popController()
    }
    
    func popController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
