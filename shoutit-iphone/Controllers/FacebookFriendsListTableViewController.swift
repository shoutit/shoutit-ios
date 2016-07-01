//
//  FacebookFriendsListTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 30/05/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class FacebookFriendsListTableViewController: ProfilesListTableViewController {
    
    var fbRefreshControl = UIRefreshControl()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InviteFriends.setTitle(NSLocalizedString("Friends not on the list? Send them an invite!", comment: ""), forState: UIControlState.Normal)
                
        self.fbRefreshControl.attributedTitle = NSAttributedString(string: "")
        self.fbRefreshControl.addTarget(self, action: #selector(fbRefresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(fbRefreshControl)
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribeNext { (event) in
            
            if event.eventType() == .ProfileChange {
                self.viewModel.pager.refreshContent()
            }
            
        }.addDisposableTo(disposeBag)
    }
    
    func fbRefresh(sender:AnyObject) {
        self.loadRefreshedList()
    }
    
    func loadRefreshedList() {
            if self.fbRefreshControl.refreshing {
                self.fbRefreshControl.endRefreshing()
            }
        self.viewModel.pager.refreshContent()
    }
    
}
