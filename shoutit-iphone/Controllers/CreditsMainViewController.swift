//
//  CreditsMainViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 10/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class CreditsMainViewController: UITableViewController {

    weak var flowDelegate : FlowController?
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var creditsLabel : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let profile = Account.sharedInstance.user as? DetailedProfile {
            fillWithLoggedUser(profile)
        }
    }
    
    func setupRx() {
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.fillWithStats(stats)
        }.addDisposableTo(disposeBag)
        
    }
    
    func fillWithLoggedUser(user: DetailedProfile) {
        fillWithStats(user.stats)
    }

    func fillWithStats(stats: ProfileStats?) {
        self.creditsLabel?.text = "\(stats?.credit ?? 0)"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            showTransactions()
        case (1,0):
            completeProfile()
        case (1,1):
            sharingOnFacebook()
        case (1,2):
            invitingFriends()
        case (1,3):
            listningToFriends()
        case (2,0):
            promotingShouts()
        default:
            break
        }
    }
    
    func showTransactions() {
        self.flowDelegate?.showCreditTransactions()
    }
    
    func completeProfile() {
        let completeAction = UIAlertAction(title: NSLocalizedString("Complete Profile", comment: ""), style: .Default) { (action) in
            self.flowDelegate?.showEditProfile()
        }
        
        showAlertWith(NSLocalizedString("Completing your Profile", comment: ""), message: NSLocalizedString("Complete your profile to earn 1 Shoutit Credit", comment: ""), actions: [completeAction])
    }
    
    func sharingOnFacebook() {
        let completeAction = UIAlertAction(title: NSLocalizedString("Create Shout", comment: ""), style: .Default) { (action) in
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.RootControllerShouldOpenNavigationItem, object: self, userInfo: ["item": NavigationItem.CreateShout.rawValue])
        }
        
        showAlertWith(NSLocalizedString("Sharing of Facebook", comment: ""), message: NSLocalizedString("Earn 1 Shoutit Credit for each shout you publicly share on Facebook", comment: ""), actions: [completeAction])
    }
    
    func invitingFriends() {
        let completeAction = UIAlertAction(title: NSLocalizedString("Invite Friends", comment: ""), style: .Default) { (action) in
            self.flowDelegate?.showInviteFriends()
        }
        
        showAlertWith(NSLocalizedString("Inviting friends", comment: ""), message: NSLocalizedString("Earn 1 Shoutit Credit whenever a friend you invited signs up", comment: ""), actions: [completeAction])
    }
    
    func listningToFriends() {
        let completeAction = UIAlertAction(title: NSLocalizedString("Find Friends", comment: ""), style: .Default) { (action) in
            self.flowDelegate?.showInviteFriends()
        }
        
        showAlertWith(NSLocalizedString("Listening of friends", comment: ""), message: NSLocalizedString("Earn up to 10 Shoutit Credits for finding your friends and listening to them", comment: ""), actions: [completeAction])
    }
    
    func promotingShouts() {
        self.flowDelegate?.showPromotingShouts()
    }
    
    func showAlertWith(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .Cancel, handler: { action in }))
        
        actions.each({ (action) in
            alert.addAction(action)
        })
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}
