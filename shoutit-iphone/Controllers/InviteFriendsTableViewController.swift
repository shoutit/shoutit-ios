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
import ContactsPicker
import MBProgressHUD

class InviteFriendsTableViewController: UITableViewController {
    
    var flowDelegate : FlowController?
    
    private let disposeBag = DisposeBag()
    private var addressBook : AddressBook?

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
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
        
        let controller = Wireframe.profileListController()
        
        controller.viewModel = SuggestedUsersViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("SUGGESTED USERS", comment: "")
        
        controller.navigationItem.title = NSLocalizedString("Suggestions", comment: "")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.showViewController(controller, sender: nil)

    }
    
    private func showSuggestedPages() {
        
        let controller = Wireframe.profileListController()
        
        controller.viewModel = SuggestedPagesViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("SUGGESTED USERS", comment: "")
        
        controller.navigationItem.title = NSLocalizedString("Suggestions", comment: "")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.showViewController(controller, sender: nil)
        
    }
    
    private func findFacebookFriends() {
        if !Account.sharedInstance.facebookManager.hasPermissions(.UserFriends) {
            Account.sharedInstance.facebookManager.extendUserReadPermissions([.UserFriends], viewController: self).subscribe { (event) in
                switch event {
                case .Next(_):
                    self.showFacebookContacts()
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
        
        showFacebookContacts()
    }
    
    func showFacebookContacts() {
        let controller = Wireframe.facebookProfileListController()
        
        controller.viewModel = MutualProfilesViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("Facebook Friends", comment: "")
        
        controller.navigationItem.title = NSLocalizedString("Find Friends", comment: "")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
        })
        
        self.navigationController?.showViewController(controller, sender: nil)
    }
    
    private func findContactsFriends() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        do {
            self.addressBook = try AddressBook()
            
            self.addressBook?.requestAccessToAddressBook({ [weak self] (access, error) -> Void in
                
                let queryBuilder = self?.addressBook?.queryBuilder()
                
                queryBuilder?.queryAsync({ (results, error) in
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    
                    guard let contacts = results else {
                        self?.showErrorMessage(NSLocalizedString("We couldnt find any contacts in your address book", comment: ""))
                        return
                    }
                    
                    self?.contactsFetched(contacts)
                })
                
            })
        } catch {
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            self.showErrorMessage(NSLocalizedString("We can't access your contacts book. Please go to Settings and make sure that you grant access for Shoutit app.", comment: ""))
        }
    }
    
    private func contactsFetched(contacts: [ContactProtocol]) {
        
        let params = ContactsParams(contacts: contacts.map({$0.toContact()}))
        
        APIProfileService.updateProfileContacts(params).subscribe { [weak self] (event) in
            switch event {
            case .Next(_):
                self?.showUserContacts()
            case .Error(let error):
                self?.showError(error)
            default: break
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    private func showUserContacts() {
        let controller = Wireframe.profileListController()
        
        controller.viewModel = MutualContactsViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("Contacts Friends", comment: "")
        
        controller.navigationItem.title = NSLocalizedString("Find Friends", comment: "")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.showViewController(controller, sender: nil)

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