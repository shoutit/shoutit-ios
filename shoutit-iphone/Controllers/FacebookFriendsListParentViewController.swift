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
    
    private let disposeBag = DisposeBag()
    
    weak var flowDelegate : FlowController?

    var eventHandler: ProfilesListEventHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteFriends.setTitle(NSLocalizedString("Friends not on the list? Send them an invite!", comment: ""), forState: UIControlState.Normal)
    }
    
    
    @IBAction func inviteFriendsAction(sender: AnyObject) {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let facebookListController = segue.destinationViewController as? FacebookFriendsListTableViewController {

            facebookListController.viewModel = MutualProfilesViewModel(showListenButtons: true)
            facebookListController.viewModel.sectionTitle = NSLocalizedString("Facebook Friends", comment: "")
            facebookListController.eventHandler = SelectProfileProfilesListEventHandler(choiceHandler: { [weak self] (profile) in
                self?.flowDelegate?.showProfile(profile)
                })
        }
    }
}

extension FacebookFriendsListParentViewController : FBSDKAppInviteDialogDelegate {
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
    }
}