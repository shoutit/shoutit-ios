//
//  BaseTableViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initializeViewModel() {
        assertionFailure("You must override this method in child class [e.g - \nviewModel = ClubFeedViewModel(viewController: self)\n]")
    }
    
}

