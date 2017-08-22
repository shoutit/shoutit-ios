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
    case horizontalGrid
    case verticalGrid
    case verticalList
    
    func collectionLayoutDisplayable() -> ShoutCollectionLayoutDisplayable! {
        switch self {
        case .horizontalGrid:
            return ShoutsHorizontalGridLayoutDelegate()
        case .verticalGrid:
            return ShoutsVerticalGridLayoutDelegate()
        case .verticalList:
            return ShoutsVerticalListLayoutDelegate()
        }
    }
}

final class ShoutsDisplayable: NSObject, UICollectionViewDelegateFlowLayout {
    
    let collectionLayoutDisplayable : ShoutCollectionLayoutDisplayable!
    
    let shoutsLayout : ShoutsLayout!
    
    var contentOffset : Variable<CGPoint>
    
    var loadNextPage : PublishSubject<Bool>?
    
    var selectedIndexPath = BehaviorSubject<IndexPath?>(value: nil)
    
    required init(layout: ShoutsLayout, offset: CGPoint = CGPoint.zero, pageSubject pSub: PublishSubject<Bool>? = nil) {
        shoutsLayout = layout
        contentOffset = Variable(offset)
        collectionLayoutDisplayable = layout.collectionLayoutDisplayable()
        loadNextPage = pSub
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionLayoutDisplayable.sizeForItem(AtIndexPath: indexPath, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let interItemSpacing = collectionLayoutDisplayable.minimumInterItemSpacingSize()
        return UIEdgeInsetsMake(interItemSpacing!.height, interItemSpacing!.width, interItemSpacing!.height, interItemSpacing!.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionLayoutDisplayable.minimumInterItemSpacingSize().width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return collectionLayoutDisplayable.headerSize(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath.on(.next(indexPath))
    }
    
    func scrollDirection() -> UICollectionViewScrollDirection {
        return collectionLayoutDisplayable.scrollDirection()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset.value = scrollView.contentOffset
        
        let shouldLoadNextPage = (scrollView.contentOffset.y) > (scrollView.contentSize.height - 1.5 * scrollView.frame.height)
        
        if shouldLoadNextPage {
            self.loadNextPage?.onNext(true)
        }
    }
    
    func applyOnLayout(_ collectionViewLayout: UICollectionViewFlowLayout?) {
        
        collectionViewLayout?.scrollDirection = scrollDirection()
        
        if let collectionView = collectionViewLayout?.collectionView {
            collectionView.delegate = self
            collectionView.performBatchUpdates({ () -> Void in
            
                collectionView.reloadItems(at: collectionView.visibleCells.map({ (cell) -> IndexPath in
                    return collectionView.indexPath(for: cell)!
                }))
                
            }, completion: nil)
        }
    }
}
