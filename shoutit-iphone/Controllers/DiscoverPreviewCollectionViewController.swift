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
                    if indexPath.item == self?.items.count {
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
        
        if indexPath.item == self.items.count {
            return collectionView.dequeueReusableCellWithReuseIdentifier("DiscoverPreviewCellSeeAll", forIndexPath: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath) as! SHShoutItemCell
    
        let element = items[indexPath.item]
        cell.bindWith(DiscoverItem: element)
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (items.count > 0) ? items.count + 1 : 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

}
