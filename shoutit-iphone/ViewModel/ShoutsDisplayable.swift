//
//  ShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ShoutsLayout {
    case HorizontalGrid
    case VerticalGrid
    case VerticalList
    
    func collectionLayoutDisplayable() -> ShoutCollectionLayoutDisplayable! {
        switch self {
        case .HorizontalGrid:
            return ShoutsHorizontalGridLayoutDelegate()
        case .VerticalGrid:
            return ShoutsVerticalGridLayoutDelegate()
        case .VerticalList:
            return ShoutsVerticalListLayoutDelegate()
        }
    }
}

class ShoutsDisplayable: NSObject, UICollectionViewDelegateFlowLayout {
    
    let collectionLayoutDisplayable : ShoutCollectionLayoutDisplayable!
    
    let shoutsLayout : ShoutsLayout!
    
    required init(layout: ShoutsLayout) {
        shoutsLayout = layout
        collectionLayoutDisplayable = layout.collectionLayoutDisplayable()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionLayoutDisplayable.sizeForItem(AtIndexPath: indexPath, collectionView: collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let interItemSpacing = collectionLayoutDisplayable.minimumInterItemSpacingSize()
        return UIEdgeInsetsMake(interItemSpacing.height, interItemSpacing.width, interItemSpacing.height, interItemSpacing.width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return collectionLayoutDisplayable.minimumInterItemSpacingSize().width
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionLayoutDisplayable.headerSize(collectionView)
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return collectionLayoutDisplayable.scrollDirection()
    }
    
    func applyOnLayout(collectionViewLayout: UICollectionViewFlowLayout?) {
        
        collectionViewLayout?.scrollDirection = scrollDirection()
        collectionViewLayout?.collectionView?.delegate = self
        
        collectionViewLayout?.collectionView?.performBatchUpdates({ () -> Void in
            collectionViewLayout?.invalidateLayout()
        }, completion: nil)
    }
}
