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
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbRefreshControl.attributedTitle = NSAttributedString(string: "")
        self.fbRefreshControl.addTarget(self, action: #selector(fbRefresh), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(fbRefreshControl)
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribe(onNext: { (event) in
            
            if event.eventType() == .ProfileChange {
                self.viewModel.pager.refreshContent()
            }
            
        }).addDisposableTo(disposeBag)
    }
    
    func fbRefresh(_ sender:AnyObject) {
        self.loadRefreshedList()
    }
    
    func loadRefreshedList() {
            if self.fbRefreshControl.isRefreshing {
                self.fbRefreshControl.endRefreshing()
            }
        self.viewModel.pager.refreshContent()
    }
    
}
