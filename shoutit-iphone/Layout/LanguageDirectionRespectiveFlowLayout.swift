//
//  LanguageDirectionRespectiveFlowLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LanguageDirectionRespectiveFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let superAttributes = super.layoutAttributesForElementsInRect(rect) else { return nil }
        guard let collectionView = collectionView else { return nil }
        let isRightToLeft = UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft
        
        if isRightToLeft {
            for attributes in superAttributes {
                var frame = attributes.frame
                frame.origin.x = collectionView.frame.size.width - attributes.frame.origin.x - 4 * collectionView.contentInset.left;
                attributes.frame = frame;
            }
        }
        
        return superAttributes
    }
}
