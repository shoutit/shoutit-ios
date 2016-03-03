//
//  EditShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class EditShoutTableViewController: CreateShoutTableViewController {

    var shout : Shout!
 
    override func createViewModel() {
        viewModel = CreateShoutViewModel(shout: shout)
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillWithShoutData()
    }
    
    func fillWithShoutData() {
        self.headerView.titleTextField.text = self.shout.title
        self.headerView.priceTextField.text = self.shout.priceText()
    }
}
