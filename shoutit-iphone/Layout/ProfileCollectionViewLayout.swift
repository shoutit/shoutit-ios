//
//  ProfileCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ProfileCollectionViewLayoutDelegate: class, ProfileCollectionInfoSupplementaryViewDataSource {
    func hidesSupplementeryView(view: ProfileCollectionViewSupplementaryView) -> Bool
    func hasContentToDisplayInSection(section: Int) -> Bool
}

final class ProfileCollectionViewLayout: UICollectionViewLayout {
    
    // supplementery views consts
    private let coverViewHeight: CGFloat                           = 211
    private let collapsedCoverViewHeight: CGFloat                  = 64
    private let infoViewHeight: CGFloat                            = 286
    private let sectionHeaderHeight: CGFloat                       = 44
    private let footerButtonHeight: CGFloat                        = 64
    private let infoOverCoverViewMargin: CGFloat                   = 41
    private let defaultInfoSupplementaryViewSectionHeight: CGFloat = 36
    
    // cells consts
    private let placeholderCellHeight: CGFloat                     = 58
    private let pagesCellHeight: CGFloat                           = 58
    private let shoutsCellHeight: CGFloat                          = 183
    private let shoutsCellSpacing: CGFloat                         = 10
    private let numberOfShoutsPerRow                               = 2
    
    // on prepare layout
    private var contentHeight: CGFloat = 0.0
    private var cachedAttributes: [ProfileCollectionViewLayoutAttributes] = []
    
    // delegate
    weak var delegate: ProfileCollectionViewLayoutDelegate?
    
    override class func layoutAttributesClass() -> AnyClass {
        return ProfileCollectionViewLayoutAttributes.self
    }
    
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
        let coverAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.Cover.kind.rawValue, withIndexPath: ProfileCollectionViewSupplementaryView.Cover.indexPath)
        let infoAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.Info.kind.rawValue, withIndexPath: ProfileCollectionViewSupplementaryView.Info.indexPath)
        
        // calculate frames
        coverAttributes.frame = CGRect(x: 0, y: contentYOffset, width: collectionWidth, height: max(coverViewHeight - contentYOffset, collapsedCoverViewHeight))
        yOffset += (coverViewHeight - infoOverCoverViewMargin)
        let height = calculateInfoSupplementaryViewHeight()
        infoAttributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: height)
        yOffset += height
        
        // add extra attributes for cover
        coverAttributes.zIndex = (collapsedCoverViewHeight >= coverViewHeight - contentYOffset) ? 10 : 0
        coverAttributes.collapseProgress = min(1, max(0, contentYOffset / (coverViewHeight - collapsedCoverViewHeight)))
        coverAttributes.segmentScrolledUnderCoverViewLength = max(0, contentYOffset - (coverViewHeight - collapsedCoverViewHeight))
        
        // add extra attributes for info
        infoAttributes.zIndex = 5
        infoAttributes.scaleFactor = max(coverViewHeight - contentYOffset, collapsedCoverViewHeight)/(coverViewHeight - collapsedCoverViewHeight)
        
        cachedAttributes.append(coverAttributes)
        cachedAttributes.append(infoAttributes)
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.PagesSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        // layout for pages cells
        if let delegate = delegate where delegate.hasContentToDisplayInSection(ProfileCollectionViewSection.Pages.rawValue) == false {
            addPlaceholderCellForSection(ProfileCollectionViewSection.Pages.rawValue, yOffset: &yOffset)
        } else {
            for item in 0 ..< collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Pages.rawValue) {
                let indexPath = NSIndexPath(forItem: item, inSection: ProfileCollectionViewSection.Pages.rawValue)
                let attributes = ProfileCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: pagesCellHeight)
                cachedAttributes.append(attributes)
                
                yOffset += pagesCellHeight
            }
        }
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.CreatePageButtonFooter,
                                                         height: footerButtonHeight,
                                                         yOffset: &yOffset)
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.ShoutsSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        // layout for shouts cells
        if let delegate = delegate where delegate.hasContentToDisplayInSection(ProfileCollectionViewSection.Shouts.rawValue) == false {
            addPlaceholderCellForSection(ProfileCollectionViewSection.Shouts.rawValue, yOffset: &yOffset)
        } else {
            let cellWidth = floor((collectionWidth - 3 * shoutsCellSpacing) * 0.5)
            for item in 0 ..< collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Shouts.rawValue) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: ProfileCollectionViewSection.Shouts.rawValue)
                let attributes = ProfileCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                let leftCell = item % numberOfShoutsPerRow == 0
                let x = leftCell ? shoutsCellSpacing : cellWidth + CGFloat(numberOfShoutsPerRow) * shoutsCellSpacing
                attributes.frame = CGRect(x: x, y: yOffset, width: cellWidth, height: shoutsCellHeight)
                cachedAttributes.append(attributes)
                
                let isLastCell = item + 1 == collectionView.numberOfItemsInSection(ProfileCollectionViewSection.Shouts.rawValue)
                if !leftCell || isLastCell {
                    yOffset += shoutsCellHeight
                    if (!isLastCell) {
                        yOffset += shoutsCellSpacing
                    }
                }
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
    
    // MARK: - Helpers
    
    private func addFullWidthAttributesForSupplementeryView(supplementary: ProfileCollectionViewSupplementaryView, var height: CGFloat, inout yOffset: CGFloat) {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return
        }
        
        let attributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: supplementary.kind.rawValue, withIndexPath: supplementary.indexPath)
        if let delegate = delegate where delegate.hidesSupplementeryView(supplementary) {
            height = 0
            attributes.hidden = true
        }
        attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: height)
        attributes.zIndex = 5
        cachedAttributes.append(attributes)
        
        yOffset += height
    }
    
    private func addPlaceholderCellForSection(section: Int, inout yOffset: CGFloat) {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return
        }
        
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let attributes = ProfileCollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: placeholderCellHeight)
        cachedAttributes.append(attributes)
        yOffset += placeholderCellHeight
    }
    
    private func calculateInfoSupplementaryViewHeight() -> CGFloat {
        
        var height = infoViewHeight
        
        if let delegate = delegate {
            
            for string in [delegate.websiteString, delegate.dateJoinedString, delegate.locationString] {
                if string == nil || string!.isEmpty {
                    height -= defaultInfoSupplementaryViewSectionHeight
                }
            }
            
            let descriptionSectionHeight = descriptionViewHeightForText(delegate.descriptionText)
            height += (descriptionSectionHeight - defaultInfoSupplementaryViewSectionHeight)
        }
        
        return height
    }
    
    func descriptionViewHeightForText(text: String?) -> CGFloat {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return defaultInfoSupplementaryViewSectionHeight
        }
        
        guard let text = text where text.characters.count > 0 else {
            return 0
        }
        
        let horizontalMargins: CGFloat = 50 + 16
        let size = CGSize(width: collectionWidth - horizontalMargins, height: CGFloat.max)
        let textSize = (text as NSString).boundingRectWithSize(size , options: [NSStringDrawingOptions.UsesLineFragmentOrigin], attributes: [NSFontAttributeName : UIFont.systemFontOfSize(12)], context: nil).size
        let verticalMargins: CGFloat = 11 + 11
        return max(textSize.height + verticalMargins, defaultInfoSupplementaryViewSectionHeight)
    }
}
