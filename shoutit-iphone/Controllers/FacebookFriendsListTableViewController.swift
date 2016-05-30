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
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribeNext { (event) in
            
            if event.eventType() == .ProfileChange {
                self.viewModel.pager.refreshContent()
            }
            
        }.addDisposableTo(disposeBag)
    }
}
