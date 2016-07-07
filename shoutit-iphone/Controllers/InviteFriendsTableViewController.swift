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
import ShoutitKit
import AddressBook
import Contacts

class InviteFriendsTableViewController: UITableViewController {
    
    weak var flowDelegate : FlowController?
    
    private let disposeBag = DisposeBag()
    private var addressBook : AddressBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "SectionHeaderWithDetailsButton", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeaderWithDetailsButton")
    }
    
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
        case (2,2):
            inviteTwitterFriends()
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionHeader = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("SectionHeaderWithDetailsButton") as? SectionHeaderWithDetailsButton {
            sectionHeader.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            sectionHeader.infoButton.hidden = section == 0
            sectionHeader.infoButton.tag = section
            sectionHeader.infoButton.addTarget(self, action: #selector(showSectionAlert), forControlEvents: .TouchUpInside)
            return sectionHeader
        }
        
        return nil
    }
    
    func showSectionAlert(button: UIButton) {
        if button.tag == 1 {
            self.showFindFriendsAlert()
        } else if button.tag == 2 {
            self.showInviteFriendsAlert()
        }
    }
    
    func showFindFriendsAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: ""), message: NSLocalizedString("Earn up to 10 Shoutit Credits for finding your friends and listening to them", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (alertaction) in
            
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showInviteFriendsAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: ""), message: NSLocalizedString("Earn 1 Shoutit Credit whenever a friend you invited signs up", comment: ""), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (alertaction) in
            
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
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
        
        controller.navigationItem.title = NSLocalizedString("Find Friends", comment: "")
        controller.flowDelegate = self.flowDelegate
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
                        self?.showErrorMessage(NSLocalizedString("We couldn't find any contacts in your address book", comment: ""))
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