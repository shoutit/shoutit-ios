//
//  ShoutCollectionDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ShoutCollectionLayoutDisplayable {
    
    func sizeForItem(AtIndexPath indexPath: NSIndexPath!, collectionView: UICollectionView) -> CGSize!
    func minimumInterItemSpacingSize() -> CGSize!
    func headerSize(collectionView: UICollectionView) -> CGSize!
    func scrollDirection() -> UICollectionViewScrollDirection
}

// MARK: Vertical List

protocol ShoutVerticalListLayoutDisplayable : ShoutCollectionLayoutDisplayable {}

extension ShoutVerticalListLayoutDisplayable {
    
    func itemHeight() -> CGFloat { return 110.0 }
    
    func sizeForItem(AtIndexPath indexPath: NSIndexPath!, collectionView: UICollectionView) -> CGSize! {
        return CGSize(width: collectionView.bounds.width - 2 * minimumInterItemSpacingSize().width, height: itemHeight())
    }
    
    func minimumInterItemSpacingSize() -> CGSize! {
        return CGSize(width: 10.0, height: 10.0)
    }
    
    func headerSize(collectionView: UICollectionView) -> CGSize! {
        return CGSizeZero
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return .Vertical
    }
}

// MARK: Vertical Grid

protocol ShoutVerticalGridLayoutDisplayable : ShoutCollectionLayoutDisplayable {}

extension ShoutVerticalGridLayoutDisplayable {
    
    func itemHeight() -> CGFloat { return 170.0 }
    
    func sizeForItem(AtIndexPath indexPath: NSIndexPath!, collectionView: UICollectionView) -> CGSize! {
        return CGSize(width: (collectionView.bounds.width - 3 * minimumInterItemSpacingSize().width) * 0.5, height: itemHeight())
    }
    
    func minimumInterItemSpacingSize() -> CGSize! {
        return CGSize(width: 10.0, height: 10.0)
    }
    
    func headerSize(collectionView: UICollectionView) -> CGSize! {
        return CGSizeZero
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return .Vertical
    }
}

// MARK: Horizontal Grid

protocol ShoutHorizontalGridLayoutDisplayable : ShoutCollectionLayoutDisplayable {}

extension ShoutHorizontalGridLayoutDisplayable {
    
    func sizeForItem(AtIndexPath indexPath: NSIndexPath!, collectionView: UICollectionView) -> CGSize! {
        return CGSize(width: 120.0, height: 120.0)
    }
    
    func minimumInterItemSpacingSize() -> CGSize! {
        return CGSize(width: 10.0, height: 10.0)
    }
    
    func headerSize(collectionView: UICollectionView) -> CGSize! {
        return CGSizeZero
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return .Horizontal
    }
}
