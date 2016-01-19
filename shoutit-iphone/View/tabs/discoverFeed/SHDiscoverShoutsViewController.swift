//
//  SHDiscoverShoutsViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/18/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverShoutsViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: SHDiscoverShoutsViewModel?
    var discoverId: String?
    var viewType: ShoutViewType = .GRID {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.registerNib(UINib(nibName: Constants.CollectionViewCell.SHDiscoverShoutCell, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: Constants.CollectionViewCell.SHDiscoverShoutCell)
        self.collectionView.registerNib(UINib(nibName: Constants.CollectionViewCell.SHDiscoverShoutListCell, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: Constants.CollectionViewCell.SHDiscoverShoutListCell)
        self.collectionView.dataSource = viewModel
        self.collectionView.delegate = viewModel
        setPullToRefresh()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHDiscoverShoutsViewModel(viewController: self)
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
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK - Private
    private func setPullToRefresh() {
        self.collectionView?.addPullToRefreshWithActionHandler({ () -> Void in
            self.viewModel?.pullToRefresh()
        })
        
        self.collectionView?.addInfiniteScrollingWithActionHandler({ () -> Void in
            self.viewModel?.triggerLoadMore()
        })
    }
    
    deinit {
        viewModel?.destroy()
    }
}
