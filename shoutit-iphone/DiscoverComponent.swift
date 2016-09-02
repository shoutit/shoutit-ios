//
//  DiscoverComponent.swift
//  shoutit
//
//  Created by Piotr Bernad on 01.09.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

class DiscoverComponent: BasicComponent {

    private let disposeBag = DisposeBag()
    
    var items : [DiscoverItem] = []
    
    var maximumDiscoverItems = 4
    
    var viewModel : DiscoverPreviewViewModel!
    
    lazy var sectionHeader : HomeSectionHeader = {
        let header = HomeSectionHeader.instanceFromNib()
        
        header.backgroundColor = UIColor.whiteColor()
        header.leftLabel.text = NSLocalizedString("Discover", comment: "")
        
        return header
    }()
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = AutoInstrictSizeCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.scrollDirection = .Vertical
        
        collection.dataSource = self
        collection.backgroundColor = UIColor.whiteColor()
        collection.delegate = self
        collection.scrollEnabled = false
        
        collection.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        collection.register(DiscoverCardCollectionViewCell)
        
        collection.invalidateIntrinsicContentSize()
        
        return collection
    }()
    
    override func loadContent() {
        // automatically loaded
        let viewModel = DiscoverPreviewViewModel()
        
        self.isLoading = true
        
        viewModel.dataSource
            .observeOn(MainScheduler.instance)
            .subscribeNext{ [weak self] (items) -> Void in
                self?.items = items
                self?.collectionView.reloadData()
                self?.isLoaded = true
                self?.isLoading = false
            }
            .addDisposableTo(self.disposeBag)
        
        self.viewModel = viewModel
    }

}

extension DiscoverComponent : ComponentStackViewRepresentable {
    func stackViewRepresentation() -> [UIView] {
        return [self.sectionHeader, self.collectionView]
    }
}

extension DiscoverComponent : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 3 * 10.0) * 0.5
        
        return CGSizeMake(width, width * 1.2)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
    }
}

extension DiscoverComponent : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(items.count, maximumDiscoverItems)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : DiscoverCardCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let element = items[indexPath.item]
        
        cell.bindWithDiscoverItem(element)
        
        return cell
    }
    
}