//
//  SHDiscoverFeedViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/6/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedViewController: BaseViewController {

    private var viewModel: SHDiscoverFeedViewModel?
    var discoverId: String?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.registerNib(UINib(nibName: Constants.CollectionViewCell.SHDiscoverShoutCell, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: Constants.CollectionViewCell.SHDiscoverShoutCell)
        self.collectionView.registerClass(SHExtraDiscoverCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCell.SHExtraDiscoverCell)
        self.collectionView.delegate = viewModel
        self.collectionView.dataSource = viewModel
        viewModel?.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func initializeViewModel() {
        viewModel = SHDiscoverFeedViewModel(viewController: self)
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
    
    deinit {
        viewModel?.destroy()
    }
   

}
