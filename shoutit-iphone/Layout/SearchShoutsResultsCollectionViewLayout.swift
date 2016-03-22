//
//  SearchShoutsResultsCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol SearchShoutsResultsCollectionViewLayoutDelegate: class {
    func sectionTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType
    func cellTypeForIndexPath(indexPath: NSIndexPath) -> SearchShoutsResultsCollectionViewLayout.CellType
}

final class SearchShoutsResultsCollectionViewLayout: UICollectionViewLayout {
    
    enum SectionType {
        case Regular
        case LayoutModeDependent
        
        var headerKind: String {
            switch self {
            case .Regular:
                return "SearchShoutsResultsCategoriesHeaderSupplementeryView"
            case .LayoutModeDependent:
                return "SearchShoutsResultsShoutsHeaderSupplementeryView"
            }
        }
        
        var headerReuseIdentifier: String {
            switch self {
            case .Regular:
                return "SearchShoutsResultsCategoriesHeaderSupplementeryView"
            case .LayoutModeDependent:
                return "SearchShoutsResultsShoutsHeaderSupplementeryView"
            }
        }
        
        var headerHeight: CGFloat {
            switch self {
            case .Regular:
                return 44
            case .LayoutModeDependent:
                return 50
            }
        }
    }
    
    enum CellType {
        case Regular
        case Placeholder
    }
    
    enum LayoutMode {
        case Grid
        case List
    }
    
    let mode: LayoutMode
    weak var delegate: SearchShoutsResultsCollectionViewLayoutDelegate?
    
    // consts
    private let cellSpacing: CGFloat = 10
    private let firstCellHeight: CGFloat = 150
    private let headersZIndex: Int = 10
    
    // on prepare layout
    private var contentHeight: CGFloat = 0.0
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    
    required init?(coder aDecoder: NSCoder) {
        self.mode = .Grid
        super.init(coder: aDecoder)
    }
    
    init(mode: LayoutMode) {
        self.mode = mode
        super.init()
    }
    
    override func prepareLayout() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // set some initial values
        cachedAttributes = []
        var yPosition: CGFloat = 0
        
        // collect data
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        let numberOfSections = collectionView.numberOfSections()
        let categoriesSectionIndex: Int? = numberOfSections == 1 ? nil : 1
        let shoutsSectionIndex: Int = numberOfSections == 1 ? 1 : 2
        
        // calculate widths
        let fullWidthCellWidth = collectionWidth - 2 * cellSpacing
        let regularCellWidth = floor((collectionWidth - 3 * cellSpacing) * 0.5)
        
        // calculate heights
        let regularCellHeight = regularCellWidth
        let categoriesSectionHeight: CGFloat?
        if let categoriesSectionIndex = categoriesSectionIndex {
            let numberOfItems = collectionView.numberOfItemsInSection(categoriesSectionIndex)
            let numberOfRows = (numberOfItems - 1) / 2 + (numberOfItems % 2) + 1
            categoriesSectionHeight = CGFloat(numberOfRows) * regularCellHeight + CGFloat(numberOfRows + 1) * cellSpacing
        } else {
            categoriesSectionHeight = nil
        }
        let shoutsSectionHeight: CGFloat
        do {
            let numberOfItems = collectionView.numberOfItemsInSection(shoutsSectionIndex)
            let numberOfRows = numberOfItems / 2 + numberOfItems % 2
            shoutsSectionHeight = CGFloat(numberOfRows) * regularCellHeight + CGFloat(numberOfRows + 1) * cellSpacing
        }
        
        // categories section attributes
        if let categoriesSectionIndex = categoriesSectionIndex, categoriesSectionHeight = categoriesSectionHeight {
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: HeaderKind.Categories.rawValue, withIndexPath: HeaderKind.Categories.indexPath)
            headerAttributes.zIndex = headersZIndex
            if contentYOffset <= categoriesSectionHeight {
                headerAttributes.frame = CGRect(x: 0, y: contentYOffset, width: collectionWidth, height: categoriesHeaderHeight)
            } else {
                let y = categoriesSectionHeight - contentYOffset
                headerAttributes.frame = CGRect(x: 0, y: y, width: collectionWidth, height: categoriesHeaderHeight)
                cachedAttributes.append(headerAttributes)
            }
            yPosition += categoriesHeaderHeight
            
            if let delegate = self.delegate where delegate.sectionContentModeForSection(categoriesSectionIndex) == .Placeholder {
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: 0, inSection: shoutsSectionIndex))
                attributes.frame = CGRect(x: 0, y: yPosition, width: collectionWidth, height: placeholderHeight)
                cachedAttributes.append(attributes)
                yPosition += placeholderHeight
                yPosition += cellSpacing
                return
            }
            
            let numberOfItemsInCategoriesSection = collectionView.numberOfItemsInSection(categoriesSectionIndex)
            for item in 0..<numberOfItemsInCategoriesSection {
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: categoriesSectionIndex))
                if item == 0 {
                    attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: fullWidthCellWidth, height: firstCellHeight)
                    yPosition += firstCellHeight
                    yPosition += cellSpacing
                } else {
                    let cellIsFirstInRow = item % 2 == 1
                    let cellIsLastInSection = numberOfItemsInCategoriesSection == item + 1
                    let x = cellIsFirstInRow ? cellSpacing : regularCellHeight + 2 * cellSpacing
                    attributes.frame = CGRect(x: x, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                    if !cellIsFirstInRow || cellIsLastInSection {
                        yPosition += regularCellHeight
                        yPosition += cellSpacing
                    }
                }
                cachedAttributes.append(attributes)
            }
        }
        
        // shouts section attributes
        do {
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: HeaderKind.Shouts.rawValue, withIndexPath: HeaderKind.Shouts.indexPath)
            headerAttributes.zIndex = headersZIndex
            if let categoriesSectionHeight = categoriesSectionHeight where yPosition <= categoriesSectionHeight {
                headerAttributes.frame = CGRect(x: 0, y: yPosition, width: collectionWidth, height: shoutsHeaderHeight)
            } else {
                let y = shoutsSectionHeight + (categoriesSectionHeight == nil ? 0 : categoriesHeaderHeight) + (categoriesSectionHeight ?? 0) - contentYOffset
                headerAttributes.frame = CGRect(x: 0, y: y, width: collectionWidth, height: shoutsHeaderHeight)
            }
            yPosition += shoutsHeaderHeight
            yPosition += cellSpacing
            cachedAttributes.append(headerAttributes)
            
            if let delegate = self.delegate where delegate.sectionContentModeForSection(shoutsSectionIndex) == .Placeholder {
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: 0, inSection: shoutsSectionIndex))
                attributes.frame = CGRect(x: 0, y: yPosition, width: collectionWidth, height: placeholderHeight)
                cachedAttributes.append(attributes)
                yPosition += placeholderHeight
                yPosition += cellSpacing
                return
            }
            
            let numberOfItemsInSection = collectionView.numberOfItemsInSection(shoutsSectionIndex)
            switch mode {
            case .Grid:
                for item in 0..<numberOfItemsInSection {
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: shoutsSectionIndex))
                    let cellIsFirstInRow = item % 2 == 0
                    let cellIsLastInSection = numberOfItemsInSection == item + 1
                    let x = cellIsFirstInRow ? cellSpacing : regularCellHeight + 2 * cellSpacing
                    attributes.frame = CGRect(x: x, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                    if !cellIsFirstInRow || cellIsLastInSection {
                        yPosition += regularCellHeight
                        yPosition += cellSpacing
                    }
                    cachedAttributes.append(attributes)
                }
            case .List:
                for item in 0..<numberOfItemsInSection {
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: shoutsSectionIndex))
                    attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: collectionWidth - 2 * cellSpacing, height: regularCellHeight)
                    yPosition += regularCellHeight
                    yPosition += cellSpacing
                    cachedAttributes.append(attributes)
                }
            }
        }
        
        self.contentHeight = yPosition
    }
    
    func prepareLayoutA() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // set some initial values
        cachedAttributes = []
        var yPosition: CGFloat = 0
        
        // collect data
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        let numberOfSections = collectionView.numberOfSections()
        
        // calculate cell sizes
        let fullWidthCellWidth = collectionWidth - 2 * cellSpacing
        let regularCellWidth = floor((collectionWidth - 3 * cellSpacing) * 0.5)
        let regularCellHeight = regularCellWidth
        let cellSize = CGSize(width: regularCellWidth, height: regularCellHeight)
        
        let sectionHeaderHeights = Array(0..<numberOfSections).map{(self.delegate?.sectionTypeForSection($0) ?? .LayoutModeDependent).headerHeight}
        let sectionHeights = Array(0..<numberOfSections).map{self.calculateHeightForSection($0, inCollectionView: collectionView, forItemWithSize: cellSize)}
        
        for section in 0..<numberOfSections {
            let sectionType = delegate?.sectionTypeForSection(section) ?? .LayoutModeDependent
            
            // header attributes
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: sectionType.headerKind, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
            headerAttributes.zIndex = headersZIndex
            let headerHeight = sectionType.headerHeight
            let sectionHeight = sectionHeights[section]
            let previousHeaderHeights = sectionHeaderHeights.filter{$0.0 < section}.map{$0.1}.reduce(0) { $0 + $1 }
            let previousSectionHeights = sectionHeights.filter{$0.0 < section}.map{$0.1}.reduce(0) { $0 + $1 }
            let previousHeight = previousHeaderHeights + previousSectionHeights
            
            if contentYOffset >= previousHeight && contentYOffset <= previousHeight + sectionHeight {
                
            }
            if contentYOffset <= categoriesSectionHeight {
                headerAttributes.frame = CGRect(x: 0, y: contentYOffset, width: collectionWidth, height: categoriesHeaderHeight)
            } else {
                let y = categoriesSectionHeight - contentYOffset
                headerAttributes.frame = CGRect(x: 0, y: y, width: collectionWidth, height: categoriesHeaderHeight)
                cachedAttributes.append(headerAttributes)
            }
            
            if yPosition <= categoriesSectionHeight {
                headerAttributes.frame = CGRect(x: 0, y: yPosition, width: collectionWidth, height: shoutsHeaderHeight)
            } else {
                let y = shoutsSectionHeight + (categoriesSectionHeight == nil ? 0 : categoriesHeaderHeight) + (categoriesSectionHeight ?? 0) - contentYOffset
                headerAttributes.frame = CGRect(x: 0, y: y, width: collectionWidth, height: shoutsHeaderHeight)
            }
        }
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
    
    private func calculateHeightForSection(section: Int, inCollectionView collectionView: UICollectionView, forItemWithSize itemSize: CGSize) -> CGFloat {
        
        let numberOfItems = collectionView.numberOfItemsInSection(section)
        let sectionType = delegate?.sectionTypeForSection(section) ?? .LayoutModeDependent
        let numberOfRows: Int
        
        switch sectionType {
        case .Regular:
            numberOfRows = (numberOfItems - 1) / 2 + (numberOfItems % 2) + 1
        case .LayoutModeDependent:
            switch mode {
            case .Grid:
                numberOfRows = numberOfItems / 2 + numberOfItems % 2
            case .List:
                numberOfRows = numberOfItems
            }
        }
        
        return CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows + 1) * cellSpacing
    }
}
