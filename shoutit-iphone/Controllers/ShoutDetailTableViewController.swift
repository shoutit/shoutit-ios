//
//  ShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol ShoutDetailTableViewControllerFlowDelegate: class, ShoutDisplayable {
    
}

final class ShoutDetailTableViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var headerView: ShoutDetailTableHeaderView!
    
    // view model
    var viewModel: ShoutDetailViewModel! {
        didSet {
            viewModel.reloadSubject.debounce(0.5, scheduler: MainScheduler.instance).subscribeNext {[weak self] in
                self?.tableView.reloadData()
                self?.hydrateHeader()
                
            }.addDisposableTo(disposeBag)
        }
    }
    
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
                    collectionView.dataSource = self?.otherShoutsDataSource
                    collectionView.delegate = self
                }
                .addDisposableTo(disposeBag)
            
            dataSource.relatedShoutsCollectionViewSetSubject
                .observeOn(MainScheduler.instance)
                .subscribeNext{[weak self] (collectionView) in
                    collectionView.dataSource = self?.relatedShoutsDataSource
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
            photosPageViewController.delegate = imagesDataSource
        }
    }
    
    // children
    private var photosPageViewController: PhotoBrowserPageViewController!
    
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
        
        // display data
        hydrateHeader()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        viewModel.reloadShoutDetails()
    }
    
    // MARK: - Setup
    
    private func hydrateHeader() {
        headerView.authorNameLabel.text = viewModel.shout.user.name
        headerView.authorProfileImageView.sh_setImageWithURL(viewModel.shout.user.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        headerView.locationLabel.text = viewModel.locationString()
        headerView.shoutTypeLabel.text = viewModel.shout.type()?.title()
        headerView.titleLabel.text = viewModel.shout.title
        headerView.priceLabel.text = viewModel.priceString()
        headerView.availabilityLabel.text = ""
        
        photosPageViewController.setViewControllers(self.imagesDataSource.viewControllers(), direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        imagesDataSource.updatePageControlWithPageViewController(photosPageViewController, currentController: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pageViewController = segue.destinationViewController as? PhotoBrowserPageViewController {
            photosPageViewController = pageViewController
        }
    }
    
    
}

extension ShoutDetailTableViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assert(false)
            return
        }
        
        let cellViewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        
        guard case .Content(let shout) = cellViewModels[indexPath.row] else {
            return
        }
        
        flowDelegate?.showShout(shout)
    }
}

extension ShoutDetailTableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard let index = (collectionView as? IndexedCollectionView)?.index else {
            assert(false)
            return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
        
        let viewModels = index == 0 ? viewModel.otherShoutsCellModels : viewModel.relatedShoutsCellModels
        if let first = viewModels.first, case ShoutDetailShoutCellViewModel.Content = first {
            return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        }
        
        return CGSize(width: collectionView.bounds.width - 20, height: collectionView.bounds.height)
    }
}

