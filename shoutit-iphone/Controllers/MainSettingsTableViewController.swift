//
//  MainSettingsTableViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 06.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

class MainSettingsTableViewController: UITableViewController {

    weak var flowDelegate : FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row, indexPath.section) {
        case (0,0):
            break
        case (1,0):
            break
        case (2,0):
            break
        case (0,1):
            self.flowDelegate?.showNotifications()
        case (0,2):
            self.flowDelegate?.showTermsAndConditions()
        case (1,2):
            self.flowDelegate?.showPrivacyPolicy()
        case (2,2):
            logout()
            break
        default: break
        }
    }
    
    func logout() {
        do {
            try Account.sharedInstance.logout()
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.UserDidLogoutNotification, object: nil)
        } catch let error {
            self.navigationController?.showError(error)
        }
    }
}
