//
//  ShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol ShoutDetailTableViewControllerFlowDelegate: class {
    
}

final class ShoutDetailTableViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var headerView: ShoutDetailTableHeaderView!
    
    // view model
    var viewModel: ShoutDetailViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // navigation
    weak var flowDelegate: ShoutDetailTableViewControllerFlowDelegate?
    
    // data sources
    private var dataSource: ShoutDetailTableViewDataSource! {
        didSet {
            tableView.dataSource = dataSource
            
            dataSource.otherShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (collectionView) in
                    collectionView.delegate = self
                }
                .addDisposableTo(disposeBag)
            
            dataSource.relatedShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (collectionView) in
                    collectionView.delegate = self
                }
                .addDisposableTo(disposeBag)
            
        }
    }
    private var otherShoutsDataSource: ShoutDetailOtherShoutsCollectionViewDataSource!
    private var relatedShoutsDataSource: ShoutDetailRelatedShoutsCollectionViewDataSource!
    private var imagesDataSource: ShoutDetailImagesPageViewControllerDataSource! {
        didSet {
            photosPageViewController.dataSource = imagesDataSource
        }
    }
    
    // children
    private var photosPageViewController: UIPageViewController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup data sources
        dataSource = ShoutDetailTableViewDataSource(viewModel: viewModel)
        otherShoutsDataSource = ShoutDetailOtherShoutsCollectionViewDataSource(viewModel: viewModel)
        relatedShoutsDataSource = ShoutDetailRelatedShoutsCollectionViewDataSource(viewModel: viewModel)
        imagesDataSource = ShoutDetailImagesPageViewControllerDataSource(viewModel: viewModel)
        
        // setup table view
        tableView.estimatedRowHeight = 40
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? UIPageViewController {
            photosPageViewController = pageViewController
        }
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

