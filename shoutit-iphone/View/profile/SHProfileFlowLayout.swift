//
//  SHProfileFlowLayout.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHProfileFlowLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        super.prepareLayout()
        self.minimumInteritemSpacing = 5
        self.minimumLineSpacing = 5
        if let collectionViewFrame = self.collectionView?.frame {
            self.headerReferenceSize = CGSizeMake(collectionViewFrame.size.width, 210)
        }
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.itemSize = self.sizeCellForRowAtIndexPath()
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        attributes?.size = self.sizeCellForRowAtIndexPath()
        return attributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if (elementKind == UICollectionElementKindSectionHeader) {
            let attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
            if let collectionViewFrame = self.collectionView?.frame {
                attributes?.size = CGSizeMake(collectionViewFrame.size.width, 210)
            }
            return attributes
        }
        return nil
    }
    
    // Private
    private func sizeCellForRowAtIndexPath() -> CGSize {
        if let collectionViewFrame = self.collectionView?.frame {
            let width = collectionViewFrame.width - self.minimumInteritemSpacing - self.sectionInset.left - self.sectionInset.right - 1
            return CGSizeMake(width / 3.0 - 2.5, width / 3.0 - 2.5)
        }
        return CGSizeMake(10, 10)
    }
}
