//
//  ShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

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

final class ShoutsDisplayable: NSObject, UICollectionViewDelegateFlowLayout {
    
    let collectionLayoutDisplayable : ShoutCollectionLayoutDisplayable!
    
    let shoutsLayout : ShoutsLayout!
    
    var contentOffset : Variable<CGPoint>
    
    var loadNextPage : PublishSubject<Bool>?
    
    var selectedIndexPath = BehaviorSubject<NSIndexPath?>(value: nil)
    
    required init(layout: ShoutsLayout, offset: CGPoint = CGPointZero, pageSubject pSub: PublishSubject<Bool>? = nil) {
        shoutsLayout = layout
        contentOffset = Variable(offset)
        collectionLayoutDisplayable = layout.collectionLayoutDisplayable()
        loadNextPage = pSub
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath.on(.Next(indexPath))
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return collectionLayoutDisplayable.scrollDirection()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        contentOffset.value = scrollView.contentOffset
        
        let shouldLoadNextPage = (scrollView.contentOffset.y) > (scrollView.contentSize.height - 1.5 * scrollView.frame.height)
        
        if shouldLoadNextPage {
            self.loadNextPage?.onNext(true)
        }
    }
    
    func applyOnLayout(collectionViewLayout: UICollectionViewFlowLayout?) {
        
        collectionViewLayout?.scrollDirection = scrollDirection()
        
        if let collectionView = collectionViewLayout?.collectionView {
            collectionView.delegate = self
            collectionView.performBatchUpdates({ () -> Void in
            
                collectionView.reloadItemsAtIndexPaths(collectionView.visibleCells().map({ (cell) -> NSIndexPath in
                    return collectionView.indexPathForCell(cell)!
                }))
                
            }, completion: nil)
        }
    }
}
