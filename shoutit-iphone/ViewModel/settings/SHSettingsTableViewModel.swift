//
//  SHSettingsTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import MessageUI

class SHSettingsTableViewModel: NSObject, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    private let viewController: SHSettingsTableViewController
    private let shApiUser = SHApiUserService()
    
    required init(viewController: SHSettingsTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let user = self.viewController.user {
            self.loadUserData(user)
        }
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            if let user = self.viewController.user, let username = user.name {
                self.inviteViaMailWithText(NSLocalizedString("Check out ShoutIT app, http://www.shoutit.com", comment: "Check out ShoutIT app, http://www.shoutit.com"), subject: String(format: "%@ %@", arguments: [username, NSLocalizedString("Invitation to ShoutIT App from", comment: "Invitation to ShoutIT App from")]))
            }
        }
        
        if(indexPath.section == 1 && indexPath.row == 1) {
            self.inviteViaSMSWithText(NSLocalizedString("Check out ShoutIT app, http://www.shoutit.com", comment: "Check out ShoutIT app, http://www.shoutit.com"))
        }
        
//        if(indexPath.section == 2 && indexPath.row == 0) {
//            let ac = UIAlertController(title: NSLocalizedString("Sign Out", comment: "Sign Out"), message: NSLocalizedString("Are you sure you want to sign out?", comment: "Are you sure you want to sign out?"), preferredStyle: UIAlertControllerStyle.Alert)
//            ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
//            ac.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
//                
//            })
//        }
//        if (indexPath.section == 2 && indexPath.row == 0) {
//            [UIAlertView showConfirmationWithTitle:NSLocalizedString(@"Sign Out", @"Sign Out") message:NSLocalizedString(@"Are you sure you want to sign out?", @"Are you sure you want to sign out?") confirmation:NSLocalizedString(@"Yes", @"Yes") completionBlock:^(UIAlertView *alert, BOOL confirmed)
//                {
//                if (confirmed) {
//                [[SHLoginModel sharedModel] logout];
//                [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
//                }
//                }];
//        }
    }
    
    func inviteViaMailWithText(text: String, subject: String) {
        let controller = MFMailComposeViewController()
        if(MFMailComposeViewController.canSendMail()) {
            controller.setMessageBody(text, isHTML: false)
            controller.setSubject(subject)
            controller.mailComposeDelegate = self
            self.viewController.presentViewController(controller, animated: true, completion: nil)
        } else {
            SHProgressHUD.showError(NSLocalizedString("You cannot send an email from the app", comment: "You cannot send an email from the app"), maskType: .Black)
        }
    }
    
    func inviteViaSMSWithText(text: String) {
        let controller = MFMessageComposeViewController()
        if(MFMessageComposeViewController.canSendText()) {
            controller.body = text
            controller.messageComposeDelegate = self
            self.viewController.presentViewController(controller, animated: true, completion: nil)
        } else {
            SHProgressHUD.showError(NSLocalizedString("You cannot send a text message from the app", comment: "You cannot send a text message from the app"), maskType: .Black)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Private
    private func loadUserData(user: SHUser) {
        if let username = user.username {
            shApiUser.loadUserDetails(username, cacheResponse: { (shUser) -> Void in
                self.updateUI(shUser)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error getting user details \(error.localizedDescription)")
                    }
            }
        }
    }
    
    private func updateUI(shUser: SHUser) {
        if let facebook = shUser.linkedAccounts?.facebook, let gplus = shUser.linkedAccounts?.gplus {
            self.setSelected(self.viewController.fbLinkButton, isSelected: facebook)
            self.setSelected(self.viewController.googleLinkButton, isSelected: gplus)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if (facebook) {
                    self.viewController.fbLinkButton.enabled = false
                    self.viewController.fbLinkButton.setTitle("PRIMARY", forState: UIControlState.Normal)
                    self.viewController.fbLinkButton.backgroundColor = UIColor.lightGrayColor()
                    self.viewController.fbLinkButton.layer.borderColor = UIColor.lightGrayColor().CGColor
                } else if (gplus) {
                    self.viewController.googleLinkButton.enabled = false
                    self.viewController.googleLinkButton.setTitle("PRIMARY", forState: UIControlState.Normal)
                    self.viewController.googleLinkButton.backgroundColor = UIColor.lightGrayColor()
                    self.viewController.googleLinkButton.layer.borderColor = UIColor.lightGrayColor().CGColor
                }
            }
        }
    }
    
    private func setSelected (button: UIButton, isSelected: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let color = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
            if(!isSelected) {
                button.setTitle("LINK", forState: UIControlState.Normal)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = color?.CGColor
                button.setTitleColor(color, forState: UIControlState.Normal)
                button.backgroundColor = UIColor.whiteColor()
            } else {
                button.setTitle("UNLINK", forState: UIControlState.Normal)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = color?.CGColor
                button.backgroundColor = color
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
            button.alpha = 1
        }
    }
    
}
