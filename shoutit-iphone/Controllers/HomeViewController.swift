//
//  HomeCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 12/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var changeLayoutButton: UIButton!
    @IBOutlet weak var discoverHeight: NSLayoutConstraint!
    
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
            bindToCollectionOffset()
            
            homeShoutsController.selectedItem.asObservable().subscribeNext { [weak self] selectedShout in
                if let _ = selectedShout {
                    self?.performSegueWithIdentifier("showSingleShout", sender: nil)
                }
            }.addDisposableTo(disposeBag)
        }
        
        if let discoverParent = self.discoverParentController, collectionController = discoverParent.discoverController {
            bindToDiscoverItems(collectionController)
        }
    }
    
    func bindToDiscoverItems(discoverController: DiscoverPreviewCollectionViewController) {
        discoverController.viewModel.state.asObservable().subscribeNext({ [weak self] (state) -> Void in
            let newValue = state == .Loaded
            self?.discoverVisible = newValue
        }).addDisposableTo(disposeBag)
        
        discoverController.collectionView?.rx_modelSelected(DiscoverItem.self)
            .asDriver()
            .driveNext { [weak self] selectedShout in
                _ = DiscoverFlowController(navigationController: (self?.navigationController)!, discoverItem: selectedShout)
            }.addDisposableTo(disposeBag)
        
    }
    
    func bindToCollectionOffset() {
        
        homeShoutsController!.scrollOffset.asObservable().map({ [unowned self] (offset) -> CGFloat in
            let newHeight : CGFloat = self.maxDiscoverHeight - (offset ?? CGPointZero).y
            return max(min(self.maxDiscoverHeight, newHeight), 0)
        })
        .subscribeNext({ [weak self] (newHeight) -> Void in
            self?.layoutDiscoverSectionWith(newHeight)
        }).addDisposableTo(disposeBag)
    }
    
    func layoutDiscoverSectionWith(newHeight: CGFloat) {
        self.discoverParentController?.view.alpha = newHeight / self.maxDiscoverHeight
        self.discoverHeight.constant = newHeight
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func filterAction(sender: AnyObject) {
        notImplemented()
    }
    
    @IBAction func searchAction(sender: AnyObject) {
        notImplemented()
    }
    
    @IBAction func cartAction(sender: AnyObject) {
        notImplemented()
    }
    
}
