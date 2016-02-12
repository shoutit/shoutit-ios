//
//  ProfileCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewLayout: UICollectionViewLayout {
    
    private var cachedAttributed: [ProfileCollectionViewLayoutAttributes] = []
    
    override func prepareLayout() {
        
        guard cachedAttributed.isEmpty else {
            return
        }
        
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        let contentWidth =  collectionView.bounds.size.width
         
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        if elementKind == ProfileCollectionViewSupplementaryViewKind.Cover.rawValue {
            
        }
        
        else if elementKind == ProfileCollectionViewSupplementaryViewKind.Info.rawValue {
            
        }
        
        else if elementKind == ProfileCollectionViewSupplementaryViewKind.SectionHeader.rawValue {
            
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if newBounds == self.collectionView?.bounds {
            return false
        }
        return true
    }
}
