//
//  CreateShoutTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class CreateShoutTableViewController: UITableViewController {

    let cellIdentifier = "CreateShoutCell"
    
    var viewModel : CreateShoutViewModel! = CreateShoutViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    @IBAction func changeTypeAction(sender: AnyObject) {
        
        let actionSheetController = viewModel.changeTypeActionSheet { (alertAction) -> Void in
            guard let title = alertAction.title else {
                fatalError("Not supported action")
            }
            
            if title == "Request" {
                self.viewModel.changeToRequest()
            } else if title == "Shout" {
                self.viewModel.changeToShout()
            }
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
    }
    

}
