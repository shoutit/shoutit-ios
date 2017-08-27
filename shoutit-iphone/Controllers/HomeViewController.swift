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
    
    @IBOutlet weak var discoverHeight: NSLayoutConstraint!
    
    // navigation
    weak var flowDelegate: FlowController?
    
    fileprivate let disposeBag = DisposeBag()
    
    weak var homeShoutsController : HomeShoutsViewController?
    weak var discoverParentController : DiscoverPreviewParentController?
    
    var maxDiscoverHeight : CGFloat {
        get { return discoverVisible ? 164.0 : 0 }
    }
    
    fileprivate var discoverVisible : Bool = true {
        didSet { self.layoutDiscoverSectionWith(maxDiscoverHeight) }
    }
    
    // MARK: Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let discoverController = discoverParentController?.discoverController,
            let discoverCollection = discoverController.collectionView {
            discoverCollection.reloadData()
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupNavigationBar() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    fileprivate func setupRX() {
        
        if let discoverParent = self.discoverParentController, let collectionController = discoverParent.discoverController {
            bindToDiscoverItems(collectionController)
            bindToCollectionOffset()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let homeShouts = segue.destination as? HomeShoutsViewController {
            homeShoutsController = homeShouts
            homeShoutsController?.flowDelegate = self.flowDelegate
        }
        
        if let discover = segue.destination as? DiscoverPreviewParentController {
            discoverParentController = discover
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterAction(_ sender: AnyObject) {
        guard let homeShoutsController = self.homeShoutsController else { return }
        flowDelegate?.showFiltersWithState(homeShoutsController.viewModel.getFiltersState(), completionBlock: {[unowned self] (state) in
            self.homeShoutsController?.viewModel.applyFilters(state)
        })
    }
    
    @IBAction func searchAction(_ sender: AnyObject) {
        self.flowDelegate?.showSearchInContext(.general)
    }
    
    @IBAction func cartAction(_ sender: AnyObject) {
        notImplemented()
    }
}

// MARK: - Helpers

private extension HomeViewController {
    
    func bindToDiscoverItems(_ discoverController: DiscoverPreviewCollectionViewController) {
        discoverController.viewModel.state
            .asObservable()
            .subscribe(onNext: { [weak self] (state) -> Void in
                let newValue = state == .loaded
                self?.discoverVisible = newValue
            })
            .addDisposableTo(disposeBag)
        
        discoverController.selectedModel
            .asDriver()
            .drive(onNext: { [weak self] (item) -> Void in
                guard let item = item else { return }
                self?.flowDelegate?.showDiscoverForDiscoverItem(item)
            }).addDisposableTo(disposeBag)
        
        discoverController.seeAllSubject
            .asObservable()
            .skip(1)
            .subscribe(onNext: {[weak self] (controller) -> Void in
                self?.flowDelegate?.showDiscover()
            })
            .addDisposableTo(disposeBag)
        
    }
    
    func bindToCollectionOffset() {
        
        homeShoutsController?.scrollOffset
            .asObservable()
            .map{ [weak self] (offset) -> CGFloat in
                guard let `self` = self else { return 0 }
                let newHeight : CGFloat = self.maxDiscoverHeight - (offset ?? CGPoint.zero).y
                return max(min(self.maxDiscoverHeight, newHeight), 0)
            }
            .subscribe(onNext: { [weak self] (newHeight) -> Void in
                self?.layoutDiscoverSectionWith(newHeight)
            })
            .addDisposableTo(disposeBag)
    }
    
    func layoutDiscoverSectionWith(_ newHeight: CGFloat) {
        self.discoverParentController?.view.alpha = newHeight / self.maxDiscoverHeight
        
        if discoverHeight.constant != newHeight {
            self.discoverHeight.constant = newHeight
        }
        
        self.view.layoutIfNeeded()
    }
}
