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

final class DiscoverPreviewCollectionViewController: UICollectionViewController {
    
    let viewModel = DiscoverPreviewViewModel()
    
    private let disposeBag = DisposeBag()
    
    var items : [DiscoverItem] = []
    
    let selectedModel : Variable<DiscoverItem?> = Variable(nil)
    let seeAllSubject = BehaviorSubject<DiscoverPreviewCollectionViewController?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collection = self.collectionView {
            
            if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = CGSize(width: 50, height: 50)
                layout.minimumInteritemSpacing = 10
                layout.minimumLineSpacing = 10
            }
            
            if #available(iOS 9.0, *) {
                collectionView?.semanticContentAttribute = .ForceLeftToRight
            }
            
            if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
                collectionView?.transform = CGAffineTransformMakeScale(-1, 1)
            }
            
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
            
            viewModel.displayable.selectedIndexPath.asDriver(onErrorJustReturn: nil).driveNext({ [weak self] (indexPath) -> Void in
                
                if let indexPath = indexPath {
                    if indexPath.item == self?.indexForSeeAll() {
                        self?.seeAllSubject.onNext(self)
                        return
                    }
                    
                    let element = self?.items[indexPath.item]
                        self?.selectedModel.value = element
                }
                
            }).addDisposableTo(disposeBag)
            
            viewModel.dataSource.subscribeNext({ [weak self] (items) -> Void in
                self?.items = items
                self?.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
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
        cell.transform = collectionView.transform
        
        let element = items[indexPath.item]
        cell.bindWith(DiscoverItem: element)
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (items.count > 0) ? items.count + 1 : 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}

private extension DiscoverPreviewCollectionViewController {
    
    func indexForSeeAll() -> NSInteger {
        return self.items.count
    }
}
