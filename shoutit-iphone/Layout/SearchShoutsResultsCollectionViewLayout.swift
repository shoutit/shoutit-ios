//
//  SearchShoutsResultsCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SearchShoutsResultsCollectionViewLayout: UICollectionViewLayout {
    
    // on prepare layout
    private var contentHeight: CGFloat = 0.0
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    override func prepareLayout() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // set some initial values
        cachedAttributes = []
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        var yOffset: CGFloat = 0
        
        // create attributes
        
        // calculate frames
        
        self.contentHeight = yOffset
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        let contentWidth =  collectionView.bounds.size.width
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var array: [UICollectionViewLayoutAttributes]?
        for attributes in cachedAttributes {
            if attributes.frame.intersects(rect) {
                if array == nil {
                    array = []
                }
                array?.append(attributes)
            }
        }
        
        return array
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        for attributes in cachedAttributes {
            if attributes.representedElementKind == nil && attributes.indexPath == indexPath {
                return attributes
            }
        }
        
        return nil
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        for attributes in cachedAttributes {
            if attributes.representedElementKind == elementKind && attributes.indexPath == indexPath {
                return attributes
            }
        }
        
        return nil
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
