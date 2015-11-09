//
//  SHDiscoverFlowLayout.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 09/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFlowLayout: UICollectionViewFlowLayout {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.minimumInteritemSpacing = 5
        self.minimumLineSpacing = 5
    }
    
    func sizeCellForRowAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        if let collectionView = self.collectionView {
            let width = collectionView.frame.size.width - self.minimumInteritemSpacing - 10
            let item = indexPath.item % 13
            if item > 0 && (item % 9 == 0 || item % 10 == 0 || item % 11 == 0 || item % 12 == 0) {
                return CGSizeMake(width/2.0, width/2.0)
            }
            return CGSizeMake(width/3.0-2.5, width/3.0-2.5)
        }
        return CGSizeZero
    }
    
    func applyCellLayoutAttributes(attributes: UICollectionViewLayoutAttributes, indexPath: NSIndexPath) {
        attributes.size = self.sizeCellForRowAtIndexPath(indexPath)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let allAttributesInRect = super.layoutAttributesForElementsInRect(rect) {
            for cellAttributes in allAttributesInRect {
                self.applyCellLayoutAttributes(cellAttributes, indexPath: cellAttributes.indexPath)
            }
            return allAttributesInRect
        }
        return nil
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) {
            self.applyCellLayoutAttributes(attributes, indexPath: indexPath)
            return attributes
        }
        return nil
    }
    
}
