//
//  DiscoverPreviewCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 12/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class DiscoverPreviewCollectionViewController: UICollectionViewController {
    
    let viewModel = DiscoverPreviewViewModel()
    
    private let disposeBag = DisposeBag()
    
    var items : [DiscoverItem] = []
    
    let selectedModel : Variable<DiscoverItem?> = Variable(nil)
    let seeAllSubject = BehaviorSubject<DiscoverPreviewCollectionViewController?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let collection = self.collectionView {
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            viewModel.displayable.selectedIndexPath.asDriver(onErrorJustReturn: nil).driveNext({ [weak self] (indexPath) -> Void in
                
                if let indexPath = indexPath {
                    if indexPath.item == self?.indexForSeeAll() {
                        self?.seeAllSubject.onNext(self)
                        return
                    }
                    
                    if let modifiedIndexPath = self?.indexPathForIndexPath(indexPath) {
                        let element = self?.items[modifiedIndexPath.item]
                        self?.selectedModel.value = element
                    }
                }
                
            }).addDisposableTo(disposeBag)
            
            viewModel.dataSource.subscribeNext({ [weak self] (items) -> Void in
                self?.items = items
                self?.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
            
            if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
                collection.transform = CGAffineTransformMakeScale(-1, 1)
            }
        }

    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.item == indexForSeeAll() {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiscoverPreviewCellSeeAll", forIndexPath: indexPath)
            
            cell.transform = collectionView.transform
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath) as! SHShoutItemCell
    
        let modifiedIndexPath = indexPathForIndexPath(indexPath)
        
        let element = items[modifiedIndexPath.item]
        
        cell.bindWith(DiscoverItem: element)
        
        cell.transform = collectionView.transform
    
        return cell
    }
    
    func indexPathForIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return NSIndexPath(forItem: self.items.count - indexPath.item, inSection: indexPath.section)
        } else {
            return indexPath
        }
    }
    
    func indexForSeeAll() -> NSInteger {
        if (UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft) {
            return 0
        } else {
            return self.items.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (items.count > 0) ? items.count + 1 : 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

}
