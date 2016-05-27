//
//  InviteFriendsTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 26.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import FBSDKShareKit
import Social
import RxSwift

class InviteFriendsTableViewController: UITableViewController {
    
    var flowDelegate : FlowController?
    
    private let disposeBag = DisposeBag()

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
        
        let objectsToShare = [NSURL(string: Constants.Invite.inviteURL)!, Constants.Invite.inviteText]
        
        let activityController = UIActivityViewController(activityItems:  objectsToShare, applicationActivities: nil)
        
        activityController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
        
        self.navigationController?.presentViewController(activityController, animated: true, completion: nil)
        
    }
    
    private func showSuggestedUsers() {
        self.flowDelegate?.showSuggestedUsers()
    }
    
    private func showSuggestedPages() {
        self.flowDelegate?.showSuggestedPages()
    }
    
    private func findFacebookFriends() {
        if !Account.sharedInstance.facebookManager.hasPermissions(.UserFriends) {
            Account.sharedInstance.facebookManager.requestReadPermissionsFromViewController([.UserFriends], viewController: self).subscribe { (event) in
                switch event {
                case .Next(_):
                    self.fetchFacebookContacts()
                case .Error(LocalError.Cancelled):
                    break
                case .Error(let error):
                    self.showError(error)
                default:
                    break
                }
                }.addDisposableTo(disposeBag)
            return
        }
        
        fetchFacebookContacts()
    }
    
    func fetchFacebookContacts() {
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: [:], HTTPMethod: "GET")
        
        request.startWithCompletionHandler { [weak self] (connection, object, error) in
         
            if let error = error {
                self?.showError(error)
                return
            }
            
            print(object)
        }
    }
    
    private func findContactsFriends() {
        
    }
    
    private func inviteFacebookFriends() {
        let inviteContent = FBSDKAppInviteContent()
        
        inviteContent.appLinkURL = NSURL(string: Constants.Invite.facebookURL)
        
        FBSDKAppInviteDialog.showFromViewController(self.navigationController, withContent: inviteContent, delegate: self)
    }
    
    private func inviteTwitterFriends() {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        vc.setInitialText(Constants.Invite.inviteText)
        vc.addURL(NSURL(string: Constants.Invite.inviteURL))
        
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }
}

extension InviteFriendsTableViewController : FBSDKAppInviteDialogDelegate {
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
    }
}
