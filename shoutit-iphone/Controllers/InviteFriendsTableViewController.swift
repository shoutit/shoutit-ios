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
        
        let objectsToShare = [Constants.Invite.inviteText]
        
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
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
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
    
    private func showFacebookContacts() {
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
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
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        showProgressHUD()
        
        do {
            self.addressBook = try AddressBook()
            
            self.addressBook?.requestAccessToAddressBook({ [weak self] (access, error) -> Void in
                
                let queryBuilder = self?.addressBook?.queryBuilder()
                
                queryBuilder?.queryAsync({ (results, error) in
                    guard let contacts = results else {
                        self?.hideProgressHUD()
                        self?.showErrorMessage(NSLocalizedString("We couldnt find any contacts in your address book", comment: ""))
                        return
                    }
                    
                    self?.contactsFetched(contacts)
                })
                
            })
        } catch {
            hideProgressHUD()
            showErrorMessage(NSLocalizedString("We can't access your contacts book. Please go to Settings and make sure that you grant access for Shoutit app.", comment: ""))
        }
    }
    
    private func contactsFetched(contacts: [ContactProtocol]) {
        
        let params = ContactsParams(contacts: contacts.map({$0.toContact()}))
        
        APIProfileService.updateProfileContacts(params).subscribe { [weak self] (event) in
            self?.hideProgressHUD()
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
        
        self.showProgressHUD(true)
        
        APICreditsService.requestInvitationCode().subscribe { [weak self] (event) in
            self?.hideProgressHUD(true)
            
            switch event {
            case .Next(let code):
                    self?.inviteFriendsByFacebookUsingCode(code)
            case .Error(let error):
                    self?.showError(error)
                default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func inviteFriendsByFacebookUsingCode(code: InvitationCode) {
        let inviteContent = FBSDKAppInviteContent()
        
        inviteContent.appLinkURL = NSURL(string: Constants.Invite.facebookURL)
        inviteContent.promotionCode = code.code
        inviteContent.promotionText = NSLocalizedString("Join Shoutit", comment: "")
        
        FBSDKAppInviteDialog.showFromViewController(self, withContent: inviteContent, delegate: self)
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