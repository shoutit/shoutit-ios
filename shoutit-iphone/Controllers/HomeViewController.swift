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
            changeLayoutButton.addTarget(homeShoutsController, action: "changeCollectionViewDisplayMode", forControlEvents: .TouchUpInside)
            bindToCollectionOffset()
        }
        
        if let discoverParent = self.discoverParentController, collectionController = discoverParent.discoverController {
            bindToDiscoverItems(collectionController)
        }
    }
    
    func bindToDiscoverItems(discoverController: DiscoverPreviewCollectionViewController) {
        discoverController.viewModel.state.asObservable().subscribeNext({ (state) -> Void in
            let newValue = state == .Loaded

            if newValue != self.discoverVisible {
//                self.discoverVisible = newValue
            }
        }).addDisposableTo(disposeBag)
    }
    
    func bindToCollectionOffset() {
        
        homeShoutsController!.scrollOffset.asObservable().map({ (offset) -> CGFloat in
            let newHeight : CGFloat = self.maxDiscoverHeight - (offset ?? CGPointZero).y
            return max(min(self.maxDiscoverHeight, newHeight), 0)
        })
        .subscribeNext({ (newHeight) -> Void in
            self.layoutDiscoverSectionWith(newHeight)
        }).addDisposableTo(disposeBag)
    }
    
    func layoutDiscoverSectionWith(newHeight: CGFloat) {
        let alpha = newHeight / self.maxDiscoverHeight
        self.discoverParentController?.view.alpha = alpha
        
        self.discoverHeight.constant = newHeight
        self.view.layoutIfNeeded()
    }
    
}
