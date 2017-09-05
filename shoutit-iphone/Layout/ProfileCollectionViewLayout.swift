//
//  ProfileCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionSectionContentMode {
    case `default`, placeholder, hidden
}

protocol ProfileCollectionViewLayoutDelegate: class, ProfileCollectionInfoSupplementaryViewDataSource {
    func hidesSupplementeryView(_ view: ProfileCollectionViewSupplementaryView) -> Bool
    func sectionContentModeForSection(_ section: Int) -> ProfileCollectionSectionContentMode
}

final class ProfileCollectionViewLayout: UICollectionViewLayout {
    
    // supplementery views consts
    fileprivate let coverViewHeight: CGFloat                           = 211
    fileprivate let collapsedCoverViewHeight: CGFloat                  = 64
    fileprivate let infoViewHeight: CGFloat                            = 336
    fileprivate let sectionHeaderHeight: CGFloat                       = 44
    fileprivate let footerButtonHeight: CGFloat                        = 64
    fileprivate let infoOverCoverViewMargin: CGFloat                   = 34
    let defaultInfoSupplementaryViewSectionHeight: CGFloat = 36
    let defaultVerifyButtonHeight: CGFloat = 44
    
    // cells consts
    fileprivate let placeholderCellHeight: CGFloat                     = 58
    fileprivate let pagesCellHeight: CGFloat                           = 58
    fileprivate let shoutsCellHeight: CGFloat                          = 183
    fileprivate let shoutsCellSpacing: CGFloat                         = 10
    fileprivate let numberOfShoutsPerRow                               = 2
    
    // on prepare layout
    fileprivate var contentHeight: CGFloat = 0.0
    fileprivate var cachedAttributes: [ProfileCollectionViewLayoutAttributes] = []
    
    // delegate
    weak var delegate: ProfileCollectionViewLayoutDelegate?
    
    override class var layoutAttributesClass : AnyClass {
        return ProfileCollectionViewLayoutAttributes.self
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // set some initial values
        cachedAttributes = []
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        var yOffset: CGFloat = 0
        
        // create attributes
        // ref
        let coverAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.cover.kind.rawValue, with: ProfileCollectionViewSupplementaryView.cover.indexPath)
        let infoAttributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: ProfileCollectionViewSupplementaryView.info.kind.rawValue, with: ProfileCollectionViewSupplementaryView.info.indexPath)

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
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.listSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        // layout for pages cells
        if let delegate = delegate, delegate.sectionContentModeForSection(ProfileCollectionViewSection.pages.rawValue) == .placeholder {
            addPlaceholderCellForSection(ProfileCollectionViewSection.pages.rawValue, yOffset: &yOffset)
        } else if let delegate = delegate, delegate.sectionContentModeForSection(ProfileCollectionViewSection.pages.rawValue) == .default {
            for item in 0 ..< collectionView.numberOfItems(inSection: ProfileCollectionViewSection.pages.rawValue) {
                let indexPath = IndexPath(item: item, section: ProfileCollectionViewSection.pages.rawValue)
                let attributes = ProfileCollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: pagesCellHeight)
                cachedAttributes.append(attributes)
                
                yOffset += pagesCellHeight
            }
        }
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.createPageButtonFooter,
                                                         height: footerButtonHeight,
                                                         yOffset: &yOffset)
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.gridSectionHeader,
                                                         height: sectionHeaderHeight,
                                                         yOffset: &yOffset)
        
        // layout for shouts cells
        if let delegate = delegate, delegate.sectionContentModeForSection(ProfileCollectionViewSection.shouts.rawValue) == .placeholder {
            addPlaceholderCellForSection(ProfileCollectionViewSection.shouts.rawValue, yOffset: &yOffset)
        } else if let delegate = delegate, delegate.sectionContentModeForSection(ProfileCollectionViewSection.shouts.rawValue) == .default {
            let cellWidth = floor((collectionWidth - 3 * shoutsCellSpacing) * 0.5)
            for item in 0 ..< collectionView.numberOfItems(inSection: ProfileCollectionViewSection.shouts.rawValue) {
                
                let indexPath = IndexPath(item: item, section: ProfileCollectionViewSection.shouts.rawValue)
                let attributes = ProfileCollectionViewLayoutAttributes(forCellWith: indexPath)
                let leftCell = item % numberOfShoutsPerRow == 0
                let x = leftCell ? shoutsCellSpacing : cellWidth + CGFloat(numberOfShoutsPerRow) * shoutsCellSpacing
                attributes.frame = CGRect(x: x, y: yOffset, width: cellWidth, height: shoutsCellHeight)
                cachedAttributes.append(attributes)
                
                let isLastCell = item + 1 == collectionView.numberOfItems(inSection: ProfileCollectionViewSection.shouts.rawValue)
                if !leftCell || isLastCell {
                    yOffset += shoutsCellHeight
                    if (!isLastCell) {
                        yOffset += shoutsCellSpacing
                    }
                }
            }
        }
        
        addFullWidthAttributesForSupplementeryView(ProfileCollectionViewSupplementaryView.seeAllShoutsButtonFooter,
                                                         height: footerButtonHeight,
                                                         yOffset: &yOffset)
        
        self.contentHeight = yOffset
    }
    
    override var collectionViewContentSize : CGSize {
        
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        let contentWidth =  collectionView.bounds.size.width
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
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
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for attributes in cachedAttributes {
            if attributes.representedElementKind == nil && attributes.indexPath == indexPath {
                return attributes
            }
        }
        
        return nil
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        for attributes in cachedAttributes {
            if attributes.representedElementKind == elementKind && attributes.indexPath == indexPath {
                return attributes
            }
        }
        
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Helpers
    
    fileprivate func addFullWidthAttributesForSupplementeryView(_ supplementary: ProfileCollectionViewSupplementaryView, height h: CGFloat, yOffset: inout CGFloat) {
        
        var height = h
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return
        }
        
        
        
        let attributes = ProfileCollectionViewLayoutAttributes(forSupplementaryViewOfKind: supplementary.kind.rawValue, with: supplementary.indexPath)
        if let delegate = delegate, delegate.hidesSupplementeryView(supplementary) {
            height = 0
            attributes.isHidden = true
        }
        attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: height)
        attributes.zIndex = 5
        cachedAttributes.append(attributes)
        
        yOffset += height
    }
    
    fileprivate func addPlaceholderCellForSection(_ section: Int, yOffset: inout CGFloat) {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = ProfileCollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: 0, y: yOffset, width: collectionWidth, height: placeholderCellHeight)
        cachedAttributes.append(attributes)
        yOffset += placeholderCellHeight
    }
    
    fileprivate func calculateInfoSupplementaryViewHeight() -> CGFloat {
        
        var height = infoViewHeight
        
        if let delegate = delegate {
            
            for string in [delegate.websiteString, delegate.dateJoinedString, delegate.locationString] {
                if string == nil || string!.isEmpty {
                    height -= defaultInfoSupplementaryViewSectionHeight
                }
            }
            
            if delegate.hidesVerifyAccountButton {
                height -= defaultVerifyButtonHeight
            }
            
            let descriptionSectionHeight = descriptionViewHeightForText(delegate.descriptionText)
            height += (descriptionSectionHeight - defaultInfoSupplementaryViewSectionHeight)
        }
        
        return height
    }
    
    func descriptionViewHeightForText(_ text: String?) -> CGFloat {
        
        guard let collectionWidth = collectionView?.bounds.width else {
            return defaultInfoSupplementaryViewSectionHeight
        }
        
        guard let text = text, text.characters.count > 0 else {
            return 0
        }
        
        let horizontalMargins: CGFloat = 50 + 16
        let size = CGSize(width: collectionWidth - horizontalMargins, height: CGFloat.greatestFiniteMagnitude)
        let textSize = (text as NSString).boundingRect(with: size , options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 12)], context: nil).size
        let verticalMargins: CGFloat = 11 + 11
        let calculatedSize = ceil(verticalMargins + textSize.height)
        return max(calculatedSize, defaultInfoSupplementaryViewSectionHeight)
    }
}
