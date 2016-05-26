//
//  InviteFriendsTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class InviteFriendsTableViewController: UITableViewController {
    
    var flowDelegate : FlowController?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            showSuggestedUsers()
        case (0,1):
            showSuggestedPages()
        case (1,0):
            findFacebookFriends()
        case (1,1):
            findContactsFriends()
        case (2,0):
            inviteFacebookFriends()
        case (2,1):
            inviteTwitterFriends()
        default:
            break
        }
    }
    
    // MARK - Actions
    
    @IBAction func shareShoutitApp(sender: AnyObject) {
        
    }
    
    private func showSuggestedUsers() {
        self.flowDelegate?.showSuggestedUsers()
    }
    
    private func showSuggestedPages() {
        self.flowDelegate?.showSuggestedPages()
    }
    
    private func findFacebookFriends() {
        
    }
    
    private func findContactsFriends() {
        
    }
    
    private func inviteFacebookFriends() {
        
    }
    
    private func inviteTwitterFriends() {
        
    }
}
