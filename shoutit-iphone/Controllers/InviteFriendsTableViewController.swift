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
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var addressBook : AddressBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "SectionHeaderWithDetailsButton", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeaderWithDetailsButton")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionHeader = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderWithDetailsButton") as? SectionHeaderWithDetailsButton {
            sectionHeader.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            sectionHeader.infoButton.isHidden = section == 0
            sectionHeader.infoButton.tag = section
            sectionHeader.infoButton.addTarget(self, action: #selector(showSectionAlert), for: .touchUpInside)
            return sectionHeader
        }
        
        return nil
    }
    
    func showSectionAlert(_ button: UIButton) {
        if button.tag == 1 {
            self.showFindFriendsAlert()
        } else if button.tag == 2 {
            self.showInviteFriendsAlert()
        }
    }
    
    func showFindFriendsAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: "Invite Friends Alert Title"), message: NSLocalizedString("Earn up to 10 Shoutit Credits for finding your friends and listening to them", comment: "Invite Friends Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: { (alertaction) in
            
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func showInviteFriendsAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Earn Shoutit Credit", comment: "Invite Friends Alert Title"), message: NSLocalizedString("Earn 1 Shoutit Credit whenever a friend you invited signs up", comment: "Invite Friends Alert Message"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: LocalizedString.ok, style: .default, handler: { (alertaction) in
            
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK - Actions
    
    @IBAction func shareShoutitApp(_ sender: AnyObject) {
        
        let objectsToShare = [Constants.Invite.inviteText]
        
        let activityController = UIActivityViewController(activityItems:  objectsToShare, applicationActivities: nil)
        
        activityController.excludedActivityTypes = [UIActivityType.print, UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo]
        
        self.navigationController?.present(activityController, animated: true, completion: nil)
        
    }
    
    fileprivate func showSuggestedUsers() {
        
        let controller = Wireframe.profileListController()
        
        controller.viewModel = SuggestedUsersViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("SUGGESTED USERS", comment: "Suggested Users Section Title")
        
        controller.navigationItem.title = NSLocalizedString("Suggestions", comment: "Suggested Users Screen Title")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.show(controller, sender: nil)

    }
    
    fileprivate func showSuggestedPages() {
        
        let controller = Wireframe.profileListController()
        
        controller.viewModel = SuggestedPagesViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("SUGGESTED USERS", comment: "Suggested Users Section Title")
        
        controller.navigationItem.title = NSLocalizedString("Suggestions", comment: "Suggested Users Screen Title")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.show(controller, sender: nil)
        
    }
    
    fileprivate func findFacebookFriends() {
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        if !Account.sharedInstance.facebookManager.hasPermissions(.UserFriends) {
            Account.sharedInstance.facebookManager.extendUserReadPermissions([.UserFriends], viewController: self).subscribe { (event) in
                switch event {
                case .next(_):
                    self.showFacebookContacts()
                case .Error(LocalError.cancelled):
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
    
    fileprivate func showFacebookContacts() {
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        let controller = Wireframe.facebookProfileListController()
        
        controller.navigationItem.title = NSLocalizedString("Find Friends", comment: "Find Friends Screen Title")
        controller.flowDelegate = self.flowDelegate
        self.navigationController?.show(controller, sender: nil)
        
    }
    
    fileprivate func findContactsFriends() {
        
        guard checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
        showProgressHUD()
        
        do {
            self.addressBook = try AddressBook()
            
            self.addressBook?.requestAccessToAddressBook({ [weak self] (access, error) -> Void in
                
                let queryBuilder = self?.addressBook?.queryBuilder()
                
                queryBuilder?.queryAsync({ (results, error) in
                    guard let contacts = results else {
                        self?.hideProgressHUD()
                        self?.showErrorMessage(NSLocalizedString("We couldn't find any contacts in your address book", comment: "Find Contacts error message"))
                        return
                    }
                    
                    self?.contactsFetched(contacts)
                })
                
            })
        } catch {
            hideProgressHUD()
            showErrorMessage(NSLocalizedString("We can't access your contacts book. Please go to Settings and make sure that you grant access for Shoutit app.", comment: "Find Contacts error message"))
        }
    }
    
    fileprivate func contactsFetched(_ contacts: [ContactProtocol]) {
        
        let params = ContactsParams(contacts: contacts.map({$0.toContact()}))
        
        APIProfileService.updateProfileContacts(params).subscribe { [weak self] (event) in
            self?.hideProgressHUD()
            switch event {
            case .next(_):
                self?.showUserContacts()
            case .Error(let error):
                self?.showError(error)
            default: break
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    fileprivate func showUserContacts() {
        let controller = Wireframe.profileListController()
        
        controller.viewModel = MutualContactsViewModel(showListenButtons: true)
        
        controller.viewModel.sectionTitle = NSLocalizedString("Contacts Friends", comment: "Find Contacts Section Title")
        
        controller.navigationItem.title = NSLocalizedString("Find Friends", comment: "Find Contacts Screen Title")
        
        controller.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
            self?.flowDelegate?.showProfile(profile)
            })
        
        self.navigationController?.show(controller, sender: nil)
    }
    
    fileprivate func inviteFacebookFriends() {
        
        self.showProgressHUD(true)
        
        APICreditsService.requestInvitationCode().subscribe { [weak self] (event) in
            self?.hideProgressHUD(true)
            
            switch event {
            case .next(let code):
                    self?.inviteFriendsByFacebookUsingCode(code)
            case .Error(let error):
                    self?.showError(error)
                default: break
            }
        }.addDisposableTo(disposeBag)
    }
    
    fileprivate func inviteFriendsByFacebookUsingCode(_ code: InvitationCode) {
        let inviteContent = FBSDKAppInviteContent()
        
        inviteContent.appLinkURL = URL(string: Constants.Invite.facebookURL)
        inviteContent.promotionCode = code.code
        inviteContent.promotionText = NSLocalizedString("Join Shoutit", comment: "Invite By Facebok promotion Text")
        
        FBSDKAppInviteDialog.show(from: self, with: inviteContent, delegate: self)
    }
    
    fileprivate func inviteTwitterFriends() {
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        
        vc.setInitialText(Constants.Invite.inviteText)
        vc.add(URL(string: Constants.Invite.inviteURL))
        
        self.navigationController?.present(vc!, animated: true, completion: nil)
    }
}

extension InviteFriendsTableViewController : FBSDKAppInviteDialogDelegate {
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
    }
}
