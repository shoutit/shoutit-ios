//
//  HomeCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 12/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift


final class HomeViewController: UIViewController {
    
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var discoverHeight: NSLayoutConstraint!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    private let disposeBag = DisposeBag()
    
    weak var homeShoutsController : HomeShoutsCollectionViewController?
    weak var discoverParentController : DiscoverPreviewParentController?
    
    var maxDiscoverHeight : CGFloat {
        get { return discoverVisible ? 164.0 : 0 }
    }
    
    private var discoverVisible : Bool = true {
        didSet { self.layoutDiscoverSectionWith(maxDiscoverHeight) }
    }
    
    // MARK: Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        setupNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let discoverController = discoverParentController?.discoverController,
            discoverCollection = discoverController.collectionView {
            discoverCollection.reloadData()
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    private func setupRX() {
        if let homeShoutsController = self.homeShoutsController {
            changeLayoutButton.addTarget(homeShoutsController, action: #selector(HomeShoutsCollectionViewController.changeCollectionViewDisplayMode(_:)), forControlEvents: .TouchUpInside)
            
            homeShoutsController.selectedItem.asObservable().subscribeNext { [weak self] selectedShout in
                if let shout = selectedShout {
                    self?.flowDelegate?.showShout(shout)
                }
                }.addDisposableTo(disposeBag)
        }
        
        if let discoverParent = self.discoverParentController, collectionController = discoverParent.discoverController {
            bindToDiscoverItems(collectionController)
            bindToCollectionOffset()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let homeShouts = segue.destinationViewController as? HomeShoutsCollectionViewController {
            homeShoutsController = homeShouts
        }
        
        if let discover = segue.destinationViewController as? DiscoverPreviewParentController {
            discoverParentController = discover
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterAction(sender: AnyObject) {
        guard let homeShoutsController = self.homeShoutsController else { return }
        flowDelegate?.showFiltersWithState(homeShoutsController.viewModel.getFiltersState(), completionBlock: {[unowned self] (state) in
            self.homeShoutsController?.viewModel.applyFiltersState(state)
            self.homeShoutsController?.reloadData()
        })
    }
    
    @IBAction func searchAction(sender: AnyObject) {
        self.flowDelegate?.showSearchInContext(.General)
    }
    
    @IBAction func cartAction(sender: AnyObject) {
        notImplemented()
    }
}

// MARK: - Helpers

private extension HomeViewController {
    
    private func bindToDiscoverItems(discoverController: DiscoverPreviewCollectionViewController) {
        discoverController.viewModel.state
            .asObservable()
            .subscribeNext{ [weak self] (state) -> Void in
                let newValue = state == .Loaded
                self?.discoverVisible = newValue
            }
            .addDisposableTo(disposeBag)
        
        discoverController.selectedModel
            .asDriver()
            .driveNext {[weak self] (item) -> Void in
                guard let item = item else { return }
                self?.flowDelegate?.showDiscoverForDiscoverItem(item)
            }.addDisposableTo(disposeBag)
        
        discoverController.seeAllSubject
            .asObservable()
            .skip(1)
            .subscribeNext {[weak self] (controller) -> Void in
                self?.flowDelegate?.showDiscover()
            }
            .addDisposableTo(disposeBag)
        
    }
    
    private func bindToCollectionOffset() {
        
        homeShoutsController!.scrollOffset
            .asObservable()
            .map{ [weak self] (offset) -> CGFloat in
                guard let `self` = self else { return 0 }
                let newHeight : CGFloat = self.maxDiscoverHeight - (offset ?? CGPointZero).y
                return max(min(self.maxDiscoverHeight, newHeight), 0)
            }
            .subscribeNext{ [weak self] (newHeight) -> Void in
                self?.layoutDiscoverSectionWith(newHeight)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func layoutDiscoverSectionWith(newHeight: CGFloat) {
        self.discoverParentController?.view.alpha = newHeight / self.maxDiscoverHeight
        
        if discoverHeight.constant != newHeight {
            self.discoverHeight.constant = newHeight
        }
        
        self.view.layoutIfNeeded()
    }
}
