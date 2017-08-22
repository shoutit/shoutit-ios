//
//  SearchShoutsResultsCollectionViewLayout.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol SearchShoutsResultsCollectionViewLayoutDelegate: class {
    func sectionTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.SectionType
    func lastCellTypeForSection(_ section: Int) -> SearchShoutsResultsCollectionViewLayout.CellType
}

final class SearchShoutsResultsCollectionViewLayout: UICollectionViewLayout {
    
    enum SectionType {
        case regular
        case layoutModeDependent
        
        var headerKind: String {
            switch self {
            case .regular:
                return "SearchShoutsResultsCategoriesHeaderSupplementeryView"
            case .layoutModeDependent:
                return "SearchShoutsResultsShoutsHeaderSupplementeryView"
            }
        }
        
        var headerReuseIdentifier: String {
            switch self {
            case .regular:
                return "SearchShoutsResultsCategoriesHeaderSupplementeryView"
            case .layoutModeDependent:
                return "SearchShoutsResultsShoutsHeaderSupplementeryView"
            }
        }
        
        var headerHeight: CGFloat {
            switch self {
            case .regular:
                return 44
            case .layoutModeDependent:
                return 50
            }
        }
    }
    
    enum CellType {
        case regular
        case placeholder
    }
    
    enum LayoutMode {
        case grid
        case list
    }
    
    let mode: LayoutMode
    weak var delegate: SearchShoutsResultsCollectionViewLayoutDelegate?
    
    // consts
    fileprivate let cellSpacing: CGFloat = 10
    fileprivate let firstCellHeight: CGFloat = 150
    fileprivate let listTypeCellHeight: CGFloat = 110
    fileprivate let headersZIndex: Int = 10
    
    // on prepare layout
    fileprivate var contentHeight: CGFloat = 0.0
    fileprivate var cachedAttributes: [ShoutsCollectionViewLayoutAttributes] = []
    
    required init?(coder aDecoder: NSCoder) {
        self.mode = .grid
        super.init(coder: aDecoder)
    }
    
    init(mode: LayoutMode) {
        self.mode = mode
        super.init()
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView else {
            return
        }
        
        // set some initial values
        cachedAttributes = []
        var yPosition: CGFloat = 0
        
        // collect data
        let collectionWidth = collectionView.bounds.width
        let contentYOffset = collectionView.contentOffset.y
        let numberOfSections = collectionView.numberOfSections
        
        // calculate cell sizes
        let fullWidthCellWidth = collectionWidth - 2 * cellSpacing
        let regularCellWidth = floor((collectionWidth - 3 * cellSpacing) * 0.5)
        let regularCellHeight = regularCellWidth
        let cellSize = CGSize(width: regularCellWidth, height: regularCellHeight)
        
        let sectionHeaderHeights = Array(0..<numberOfSections).map{(self.delegate?.sectionTypeForSection($0) ?? .layoutModeDependent).headerHeight}
        let sectionHeights = Array(0..<numberOfSections).map{self.calculateHeightForSection($0, inCollectionView: collectionView, forItemWithSize: cellSize)}
        
        for section in 0..<numberOfSections {
            let sectionType = delegate?.sectionTypeForSection(section) ?? .layoutModeDependent
            
            // header attributes
            let headerAttributes = ShoutsCollectionViewLayoutAttributes(forSupplementaryViewOfKind: sectionType.headerKind, withIndexPath: IndexPath(item: 0, section: section))
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
            let cellCount = collectionView.numberOfItems(inSection: section)
            switch (sectionType, mode) {
            case (.regular, _):
                for item in 0..<cellCount {
                    let attributes = ShoutsCollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                    if item == 0 {
                        attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: fullWidthCellWidth, height: firstCellHeight)
                        yPosition += firstCellHeight
                        yPosition += cellSpacing
                    } else {
                        let cellIsFirstInRow = item % 2 == 1
                        let cellIsLastInSection = cellCount == item + 1
                        
                        if let delegate = delegate, delegate.lastCellTypeForSection(section) == .placeholder && cellIsLastInSection {
                            if !cellIsFirstInRow {
                                yPosition += cellSpacing
                                yPosition += regularCellHeight
                            }
                            attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: fullWidthCellWidth, height: regularCellHeight)
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
            case (.layoutModeDependent, .grid):
                for item in 0..<cellCount {
                    let attributes = ShoutsCollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                    let cellIsFirstInRow = item % 2 == 0
                    let cellIsLastInSection = cellCount == item + 1
                    
                    if let delegate = delegate, delegate.lastCellTypeForSection(section) == .placeholder && cellIsLastInSection {
                        if !cellIsFirstInRow {
                            yPosition += cellSpacing
                            yPosition += regularCellHeight
                        }
                        attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: fullWidthCellWidth, height: regularCellHeight)
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
            case (.layoutModeDependent, .list):
                for item in 0..<cellCount {
                    let attributes = ShoutsCollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                    attributes.mode = .expanded
                    attributes.frame = CGRect(x: cellSpacing, y: yPosition, width: collectionWidth - 2 * cellSpacing, height: listTypeCellHeight)
                    yPosition += listTypeCellHeight
                    yPosition += cellSpacing
                    cachedAttributes.append(attributes)
                }
            }
        }
        
        self.contentHeight = yPosition
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
    
    fileprivate func calculateHeightForSection(_ section: Int, inCollectionView collectionView: UICollectionView, forItemWithSize itemSize: CGSize) -> CGFloat {
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        let sectionType = delegate?.sectionTypeForSection(section) ?? .layoutModeDependent
        
        switch sectionType {
        case .regular:
            let basicNumber = (numberOfItems - 1) / 2 + (numberOfItems % 2) + 1
            let numberOfRows: Int
            if let delegate = delegate, delegate.lastCellTypeForSection(section) == .placeholder && basicNumber % 2 == 1 {
                numberOfRows = basicNumber + 1
            } else {
                numberOfRows = basicNumber
            }
            return CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows + 1) * cellSpacing
        case .layoutModeDependent:
            switch mode {
            case .grid:
                let basicNumber = numberOfItems / 2 + numberOfItems % 2
                let numberOfRows: Int
                if let delegate = delegate, delegate.lastCellTypeForSection(section) == .placeholder && basicNumber % 2 == 0 {
                    numberOfRows = basicNumber + 1
                } else {
                    numberOfRows = basicNumber
                }
                return CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows + 1) * cellSpacing
            case .list:
                let numberOfRows = numberOfItems
                return CGFloat(numberOfRows) * listTypeCellHeight + CGFloat(numberOfRows + 1) * cellSpacing
            }
        }
    }
}
