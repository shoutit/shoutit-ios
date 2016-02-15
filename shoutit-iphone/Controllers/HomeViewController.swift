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
    
    private let maxDiscoverHeight : CGFloat = 164.0
    private let disposeBag = DisposeBag()
    
    weak var homeShoutsController : HomeShoutsCollectionViewController?
    weak var discoverParentController : DiscoverPreviewParentController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let homeShouts = segue.destinationViewController as? HomeShoutsCollectionViewController {
            homeShoutsController = homeShouts
        }
        
        if let discover = segue.destinationViewController as? DiscoverPreviewParentController {
            discoverParentController = discover
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
    }
    
    func setupRX() {
        if let homeShoutsController = self.homeShoutsController {
            changeLayoutButton.addTarget(homeShoutsController, action: "changeCollectionViewDisplayMode", forControlEvents: .TouchUpInside)
            
            if let collection = homeShoutsController.collectionView {
                self.bindScrollAnimationTo(collection)
            }
        }
    }
    
    
    func bindScrollAnimationTo(collection: UICollectionView) {
        collection.rx_contentOffset
            .map({ (offset) -> CGFloat in
                var newHeight : CGFloat = self.maxDiscoverHeight - offset.y
                
                if newHeight < 0 {
                    newHeight = 0
                } else if newHeight > self.maxDiscoverHeight {
                    newHeight = self.maxDiscoverHeight
                }
                return newHeight
            })
            .subscribeNext({ (newHeight) -> Void in
                
                let alpha = newHeight / self.maxDiscoverHeight
                self.discoverParentController?.view.alpha = alpha
                
                self.discoverHeight.constant = newHeight
                self.view.layoutIfNeeded()
                
            })
            .addDisposableTo(disposeBag)
    }
}
