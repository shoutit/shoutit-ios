//
//  FacebookFriendsListParentViewController.swift
//  shoutit
//
//  Created by Abhijeet Chaudhary on 07/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import FBSDKShareKit
import Social
import ShoutitKit

class FacebookFriendsListParentViewController: UIViewController {

    @IBOutlet weak var inviteFriends: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    weak var flowDelegate : FlowController?

    var eventHandler: ProfilesListEventHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteFriends.setTitle(NSLocalizedString("Friends not on the list? Send them an invite!", comment: "Facebook Friends Button Title"), for: UIControlState())
    }
    
    
    @IBAction func inviteFriendsAction(_ sender: AnyObject) {
        self.showProgressHUD(true)
            
            APICreditsService.requestInvitationCode().subscribe { [weak self] (event) in
                self?.hideProgressHUD(true)
                
                switch event {
                case .next(let code):
                    self?.inviteFriendsByFacebookUsingCode(code)
                case .error(let error):
                    self?.showError(error)
                default: break
                }
                }.addDisposableTo(disposeBag)
            
        }
    
    fileprivate func inviteFriendsByFacebookUsingCode(_ code: InvitationCode) {
        let inviteContent = FBSDKAppInviteContent()
        
        inviteContent.appLinkURL = URL(string: Constants.Invite.facebookURL)
        inviteContent.promotionCode = code.code
        inviteContent.promotionText = NSLocalizedString("Join Shoutit", comment: "Invite Promotion Text")
        
        FBSDKAppInviteDialog.show(from: self, with: inviteContent, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let facebookListController = segue.destination as? FacebookFriendsListTableViewController {

            facebookListController.viewModel = MutualProfilesViewModel(showListenButtons: true)
            facebookListController.viewModel.sectionTitle = NSLocalizedString("Facebook Friends", comment: "Facebook Friends Screen Title")
            facebookListController.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
                self?.flowDelegate?.showProfile(profile)
                })
        }
    }
}

extension FacebookFriendsListParentViewController : FBSDKAppInviteDialogDelegate {
    /*!
     @abstract Sent to the delegate when the app invite encounters an error.
     @param appInviteDialog The FBSDKAppInviteDialog that completed.
     @param error The error.
     */
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
    }
}
