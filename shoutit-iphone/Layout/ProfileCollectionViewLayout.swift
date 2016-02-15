//
//  ProfileCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewLayout: UICollectionViewLayout {
    
    // supplementery views consts
    private let coverViewHeight: CGFloat = 211
    private let collapsedCoverViewHeight: CGFloat = 64
    private let infoViewHeight: CGFloat = 334
    private let sectionHeaderHeight: CGFloat = 44
    private let footerButtonHeight: CGFloat = 64
    private let infoOverCoverViewMargin: CGFloat = 41
    
    // cells consts
    private let pagesCellHeight: CGFloat = 58
    private let shoutsCellHeight: CGFloat = 183
    private let shoutsCellSpacing: CGFloat = 10
    private let numberOfShoutsPerRow = 2
    
    // on prepare layout
    private var contentHeight: CGFloat = 0.0
    private var cachedAttributes: [ProfileCollectionViewLayoutAttributes] = []
    
    override class func layoutAttributesClass() -> AnyClass {
        return ProfileCollectionViewLayoutAttributes.self
    }
    
    override func prepareLayout() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        cachedAttributes = []
        
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        var yOffset: CGFloat = 0
        
        let coverAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.Cover.kind.rawValue, withIndexPath: ProfileCollectionViewSupplementaryView.Cover.indexPath)
        let infoAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.Info.kind.rawValue, withIndexPath: ProfileCollectionViewSupplementaryView.Info.indexPath)
        
        coverAttributes.frame = CGRect(x: 0, y: contentYOffset, width: collectionWidth, height: max(coverViewHeight - contentYOffset, collapsedCoverViewHeight))
        yOffset += (coverViewHeight - infoOverCoverViewMargin)
        infoAttributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: infoViewHeight)
        yOffset += infoViewHeight
        
        let reachedBreakingPoint = collapsedCoverViewHeight >= coverViewHeight - contentYOffset
        
        if reachedBreakingPoint {
            coverAttributes.zIndex = 10
        } else {
            coverAttributes.zIndex = 0
        }
        
        infoAttributes.zIndex = 5
        infoAttributes.scaleFactor = max(coverViewHeight - contentYOffset, collapsedCoverViewHeight)/coverViewHeight
        
        cachedAttributes.append(coverAttributes)
        cachedAttributes.append(infoAttributes)
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.PagesSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        // layout for pages cells
        for item in 0 ..< collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Pages.rawValue) {
            
            let indexPath = NSIndexPath(forItem: item, inSection: ProfileCollectionViewSection.Pages.rawValue)
            let attributes = ProfileCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: pagesCellHeight)
            cachedAttributes.append(attributes)
            
            yOffset += pagesCellHeight
        }
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.CreatePageButtonFooter,
                                                         height: footerButtonHeight,
                                                         yOffset: &yOffset)
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.ShoutsSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        let cellWidth = floor((collectionWidth - shoutsCellSpacing) * 0.5)
        // layout for shouts cells
        for item in 0 ..< collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Shouts.rawValue) {
            
            let indexPath = NSIndexPath(forItem: item, inSection: ProfileCollectionViewSection.Shouts.rawValue)
            let attributes = ProfileCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            let leftCell = item % numberOfShoutsPerRow == 0
            let x = leftCell ? shoutsCellSpacing : cellWidth + CGFloat(numberOfShoutsPerRow) * shoutsCellSpacing
            attributes.frame = CGRect(x: x, y: yOffset, width: cellWidth, height: shoutsCellHeight)
            cachedAttributes.append(attributes)
            
            if !leftCell || item + 1 == collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Shouts.rawValue) {
                yOffset += shoutsCellHeight
            }
        }
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.SeeAllShoutsButtonFooter,
                                                         height: footerButtonHeight,
                                                         yOffset: &yOffset)
        
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
    
    private func addFullWidthAttributesForSupplementeryView(supplementary: ProfileCollectionViewSupplementaryView, height: CGFloat, inout yOffset: CGFloat) {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return
        }
        
        let attributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: supplementary.kind.rawValue, withIndexPath: supplementary.indexPath)
        attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: height)
        attributes.zIndex = 5
        cachedAttributes.append(attributes)
        
        yOffset += height
    }
}
