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
    func lastCellTypeForSection(section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType
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
            let previousHeaderHeights = sectionHeaderHeights[0..<section].reduce(0) { $0 + $1 }
            let previousSectionHeights = sectionHeights[0..<section].reduce(0) { $0 + $1 }
            let previousHeight = previousHeaderHeights + previousSectionHeights
            
            if contentYOffset >= previousHeight && contentYOffset <= previousHeight + sectionHeight {
                headerAttributes.frame = CGRect(x: 0, y: contentYOffset, width: collectionWidth, height: headerHeight)
            } else {
                headerAttributes.frame = CGRect(x: 0, y: yPosition, width: collectionWidth, height: headerHeight)
            }
            yPosition += headerHeight
            yPosition += cellSpacing
            cachedAttributes.append(headerAttributes)
            
            // cells attributes
            let cellCount = collectionView.numberOfItemsInSection(section)
            switch (sectionType, mode) {
            case (.Regular, _):
                for item in 0..<cellCount {
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: section))
                    if item == 0 {
                        attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: fullWidthCellWidth, height: firstCellHeight)
                        yPosition += firstCellHeight
                        yPosition += cellSpacing
                    } else {
                        let cellIsFirstInRow = item % 2 == 1
                        let cellIsLastInSection = cellCount == item + 1
                        
                        if let delegate = delegate where delegate.lastCellTypeForSection(section) == .Placeholder && cellIsLastInSection {
                            if !cellIsFirstInRow {
                                yPosition += cellSpacing
                                yPosition += regularCellHeight
                            }
                            attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                        } else {
                            let x = cellIsFirstInRow ? cellSpacing : regularCellHeight + 2 * cellSpacing
                            attributes.frame = CGRect(x: x, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                        }
                        if !cellIsFirstInRow || cellIsLastInSection {
                            yPosition += regularCellHeight
                            yPosition += cellSpacing
                        }
                    }
                    cachedAttributes.append(attributes)
                }
            case (.LayoutModeDependent, .Grid):
                for item in 0..<cellCount {
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: section))
                    let cellIsFirstInRow = item % 2 == 0
                    let cellIsLastInSection = cellCount == item + 1
                    
                    if let delegate = delegate where delegate.lastCellTypeForSection(section) == .Placeholder && cellIsLastInSection {
                        if !cellIsFirstInRow {
                            yPosition += cellSpacing
                            yPosition += regularCellHeight
                        }
                        attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                    } else {
                        let x = cellIsFirstInRow ? cellSpacing : regularCellHeight + 2 * cellSpacing
                        attributes.frame = CGRect(x: x, y: yPosition, width: regularCellWidth, height: regularCellHeight)
                    }
                    if !cellIsFirstInRow || cellIsLastInSection {
                        yPosition += regularCellHeight
                        yPosition += cellSpacing
                    }
                    cachedAttributes.append(attributes)
                }
            case (.LayoutModeDependent, .List):
                for item in 0..<cellCount {
                    let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: item, inSection: section))
                    attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: collectionWidth - 2 * cellSpacing, height: regularCellHeight)
                    yPosition += regularCellHeight
                    yPosition += cellSpacing
                    cachedAttributes.append(attributes)
                }
            }
        }
        
        self.contentHeight = yPosition
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
            let basicNumber = (numberOfItems - 1) / 2 + (numberOfItems % 2) + 1
            if let delegate = delegate where delegate.lastCellTypeForSection(section) == .Placeholder && basicNumber % 2 == 1 {
                numberOfRows = basicNumber + 1
            } else {
                numberOfRows = basicNumber
            }
        case .LayoutModeDependent:
            switch mode {
            case .Grid:
                let basicNumber = numberOfItems / 2 + numberOfItems % 2
                if let delegate = delegate where delegate.lastCellTypeForSection(section) == .Placeholder && basicNumber % 2 == 0 {
                    numberOfRows = basicNumber + 1
                } else {
                    numberOfRows = basicNumber
                }
            case .List:
                numberOfRows = numberOfItems
            }
        }
        
        return CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows + 1) * cellSpacing
    }
}
