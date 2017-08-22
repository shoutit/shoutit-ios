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
import ShoutitKit

final class DiscoverPreviewCollectionViewController: UICollectionViewController {
    
    let viewModel = DiscoverPreviewViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    var items : [DiscoverItem] = []
    
    let selectedModel : Variable<DiscoverItem?> = Variable(nil)
    let seeAllSubject = BehaviorSubject<DiscoverPreviewCollectionViewController?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView() {
        
        guard let collection = self.collectionView else { return }
        
        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 50, height: 50)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
        if #available(iOS 9.0, *) {
            collectionView?.semanticContentAttribute = .forceLeftToRight
        }
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
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
        
        viewModel.dataSource
            .observeOn(MainScheduler.instance)
            .subscribeNext{ [weak self] (items) -> Void in
                self?.items = items
                self?.collectionView?.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == indexForSeeAll() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverPreviewCellSeeAll", for: indexPath)
            cell.transform = collectionView.transform
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellReuseIdentifier(), for: indexPath) as! DiscoverItemCell
        cell.transform = collectionView.transform
        
        let element = items[indexPath.item]
        cell.bindWith(DiscoverItem: element)
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (items.count > 0) ? items.count + 1 : 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

private extension DiscoverPreviewCollectionViewController {
    
    func indexForSeeAll() -> NSInteger {
        return self.items.count
    }
}
