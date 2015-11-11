//
//  SHDiscoverCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import SVPullToRefresh

class SHDiscoverCollectionViewController: BaseCollectionViewController {

    private var viewModel: SHDiscoverViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup Delegates and data Source
        self.collectionView?.delegate = viewModel
        self.collectionView?.dataSource = viewModel
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(5, 5, 5, 5)
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHDiscoverViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setPullToRefresh()
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
    
    deinit {
        viewModel?.destroy()
    }
    
    // MARK - Private
    private func setPullToRefresh() {
        self.collectionView?.addPullToRefreshWithActionHandler({ () -> Void in
            self.viewModel?.pullToRefresh()
        })
    }
    
}
