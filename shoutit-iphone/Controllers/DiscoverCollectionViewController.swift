//
//  DiscoverCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class DiscoverCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var viewModel : DiscoverViewModel?
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerNibs()
        loadItems()
    }
    
    func registerNibs() {
        self.collectionView?.registerNib(UINib(nibName: "DiscoverHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.SubItems.headerIdentifier())
        self.collectionView?.registerNib(UINib(nibName: "DiscoverShoutsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DiscoverSection.Shouts.headerIdentifier())
    }
    
    func loadItems() {
        if viewModel == nil {
            viewModel = DiscoverGeneralViewModel()
        }
        
        if let vm = viewModel {
            vm.items.asObservable().subscribeNext({ [weak self] (result) -> Void in
                self?.collectionView?.reloadSections(NSIndexSet(index: 0))
            }).addDisposableTo(disposeBag)
            
            vm.shouts.asObservable().subscribeNext({ [weak self] (result) -> Void in
                self?.collectionView?.reloadSections(NSIndexSet(index: 1))
            }).addDisposableTo(disposeBag)
            
            vm.retriveDiscoverItems()
        }
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        if section == 0 {
            return viewModel.discoverItems().count
        }
        
        return viewModel.shoutsItems().count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.viewModel!.cellIdentifierForSection(indexPath.section), forIndexPath: indexPath)
    
        // Configure Shout cell
        if indexPath.section == 1 {
            if let element = self.viewModel?.shoutsItems()[indexPath.item] {
                let shoutCell = cell as! SHShoutItemCell
                shoutCell.bindWith(Shout: element)
            }
        }
        
        // Configure Discover cell
        if indexPath.section == 0 {
            if let element = self.viewModel?.discoverItems()[indexPath.item] {
                let discoverCell = cell as! SHShoutItemCell
                discoverCell.bindWith(DiscoverItem: element)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: DiscoverSection(rawValue: indexPath.section)!.headerIdentifier(), forIndexPath: indexPath)
    }
    
    // MARK: UICollectionView Flow Layout Delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20.0, height: (section == 0 ? 140.0 : 44.0))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.viewModel!.displayable.sizeForItem(AtIndexPath: indexPath, collectionView: collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return self.viewModel!.displayable.minimumInterItemSpacingSize().width
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let interItemSpacing = self.viewModel!.displayable.minimumInterItemSpacingSize()
        
        return UIEdgeInsetsMake(interItemSpacing.height, interItemSpacing.width, interItemSpacing.height, interItemSpacing.width)
    }

}
