//
//  SHConversationsTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHConversationsTableViewController: BaseTableViewController {
    
    private var viewModel: SHConversationsTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(SHOauthToken.getFromCache()?.accessToken?.characters.count < 0) {
            SHOauthToken.goToLogin()
            SHProgressHUD.showError(NSLocalizedString("Please log in to continue", comment: "Please log in to continue"))
            return
        }
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.clearsSelectionOnViewWillAppear = true
        self.setPullToRefresh()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHConversationsTableViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Private
    private func setPullToRefresh() {
        self.tableView?.addPullToRefreshWithActionHandler({ () -> Void in
            self.viewModel?.pullToRefresh()
        })
        
//        self.tableView?.addInfiniteScrollingWithActionHandler({ () -> Void in
//            self.viewModel?.triggerLoadMore()
//        })
    }
    
    deinit {
        viewModel?.destroy()
    }
}
