//
//  HomeCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 12/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol HomeViewControllerFlowDelegate: class, ShoutDisplayable, SearchDisplayable {
    
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var discoverHeight: NSLayoutConstraint!
    
    // navigation
    weak var flowDelegate: HomeViewControllerFlowDelegate?
    
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
        
        if let discoverController = discoverParentController?.discoverController, discoverCollection = discoverController.collectionView {
            discoverCollection.reloadData()
        }
    }
    
    func setupNavigationBar() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo_navbar_white"))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let homeShouts = segue.destinationViewController as? HomeShoutsCollectionViewController {
            homeShoutsController = homeShouts
        }
        
        if let discover = segue.destinationViewController as? DiscoverPreviewParentController {
            discoverParentController = discover
        }
    }
    
    func setupRX() {
        if let homeShoutsController = self.homeShoutsController {
            changeLayoutButton.addTarget(homeShoutsController, action: "changeCollectionViewDisplayMode:", forControlEvents: .TouchUpInside)
            
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
    
    func bindToDiscoverItems(discoverController: DiscoverPreviewCollectionViewController) {
        discoverController.viewModel.state.asObservable().subscribeNext({ [weak self] (state) -> Void in
            let newValue = state == .Loaded
            self?.discoverVisible = newValue
        }).addDisposableTo(disposeBag)
        
        discoverController.selectedModel.asDriver().driveNext { (item) -> Void in
            if let item = item {
                self.flowDelegate?.showDiscoverForDiscoverItem(item)
            }
        }.addDisposableTo(disposeBag)
        
        discoverController.seeAllSubject.asObservable().skip(1).subscribeNext { (controller) -> Void in
            self.flowDelegate?.showDiscover()
        }.addDisposableTo(disposeBag)
        
    }
    
    func bindToCollectionOffset() {
        
        homeShoutsController!.scrollOffset.asObservable().map({ [weak self] (offset) -> CGFloat in
            
            if let welf = self {
                let newHeight : CGFloat = welf.maxDiscoverHeight - (offset ?? CGPointZero).y
                return max(min(welf.maxDiscoverHeight, newHeight), 0)
            }
            
            return 0
        })
        .subscribeNext({ [weak self] (newHeight) -> Void in
            self?.layoutDiscoverSectionWith(newHeight)
        }).addDisposableTo(disposeBag)
    }
    
    func layoutDiscoverSectionWith(newHeight: CGFloat) {
        self.discoverParentController?.view.alpha = newHeight / self.maxDiscoverHeight
        
        if discoverHeight.constant != newHeight {
            self.discoverHeight.constant = newHeight
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func filterAction(sender: AnyObject) {
        notImplemented()
    }
    
    @IBAction func searchAction(sender: AnyObject) {
        self.flowDelegate?.showSearchInContext(.General)
    }
    
    @IBAction func cartAction(sender: AnyObject) {
        notImplemented()
    }
    
}
