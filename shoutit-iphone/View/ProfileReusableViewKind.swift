//
//  ProfileReusableViewKind.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionViewSection: Int {
    case pages = 0
    case shouts = 1
    
    var cellReuseIdentifier: String {
        switch self {
        case .pages:
            return "ProfileCollectionViewCellKindPages"
        case .shouts:
            return "ProfileCollectionViewCellKindShouts"
        }
    }
}

enum ProfileCollectionViewSupplementaryView {
    case cover
    case info
    case listSectionHeader
    case createPageButtonFooter
    case gridSectionHeader
    case seeAllShoutsButtonFooter
    
    init?(indexPath: IndexPath) {
        for view in [ProfileCollectionViewSupplementaryView.cover, ProfileCollectionViewSupplementaryView.info, ProfileCollectionViewSupplementaryView.listSectionHeader, ProfileCollectionViewSupplementaryView.createPageButtonFooter, ProfileCollectionViewSupplementaryView.gridSectionHeader, ProfileCollectionViewSupplementaryView.seeAllShoutsButtonFooter] {
            if view.indexPath == indexPath {
                self = view
                return
            }
        }
        
        return nil
    }
    
    var indexPath: IndexPath {
        switch self {
        case .cover:
            return IndexPath(item: 0, section: 0)
        case .info:
            return IndexPath(item: 1, section: 0)
        case .listSectionHeader:
            return IndexPath(item: 2, section: 0)
        case .createPageButtonFooter:
            return IndexPath(item: 3, section: 0)
        case .gridSectionHeader:
            return IndexPath(item: 4, section: 0)
        case .seeAllShoutsButtonFooter:
            return IndexPath(item: 5, section: 0)
        }
    }
    
    var kind: ProfileCollectionViewSupplementaryViewKind {
        switch self {
        case .cover:
            return ProfileCollectionViewSupplementaryViewKind.Cover
        case .info:
            return ProfileCollectionViewSupplementaryViewKind.Info
        case .listSectionHeader, .gridSectionHeader:
            return ProfileCollectionViewSupplementaryViewKind.SectionHeader
        case .createPageButtonFooter, .seeAllShoutsButtonFooter:
            return ProfileCollectionViewSupplementaryViewKind.FooterButton
        }
    }
}

enum ProfileCollectionViewSupplementaryViewKind: String {
    case Cover          = "ProfileCollectionViewSupplementaryViewKindCover"
    case Info           = "ProfileCollectionViewSupplementaryViewKindInfo"
    case SectionHeader  = "ProfileCollectionViewSupplementaryViewKindSectionHeader"
    case FooterButton   = "ProfileCollectionViewSupplementaryViewKindFooterButton"
}
