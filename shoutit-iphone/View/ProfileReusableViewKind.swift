//
//  ProfileReusableViewKind.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionViewSection: Int {
    case Pages = 0
    case Shouts = 1
    
    var cellReuseIdentifier: String {
        switch self {
        case .Pages:
            return "ProfileCollectionViewCellKindPages"
        case .Shouts:
            return "ProfileCollectionViewCellKindShouts"
        }
    }
}

enum ProfileCollectionViewSupplementaryView {
    case Cover
    case Info
    case PagesSectionHeader
    case CreatePageButtonFooter
    case ShoutsSectionHeader
    case SeeAllShoutsButtonFooter
    
    init?(indexPath: NSIndexPath) {
        for view in [Cover, Info, PagesSectionHeader, CreatePageButtonFooter, ShoutsSectionHeader, SeeAllShoutsButtonFooter] {
            print(view.indexPath)
            print(indexPath)
            if view.indexPath == indexPath {
                self = view
                return
            }
        }
        
        return nil
    }
    
    var indexPath: NSIndexPath {
        switch self {
        case .Cover:
            return NSIndexPath(forItem: 0, inSection: 0)
        case .Info:
            return NSIndexPath(forItem: 1, inSection: 0)
        case .PagesSectionHeader:
            return NSIndexPath(forItem: 2, inSection: 0)
        case .CreatePageButtonFooter:
            return NSIndexPath(forItem: 3, inSection: 0)
        case .ShoutsSectionHeader:
            return NSIndexPath(forItem: 4, inSection: 0)
        case .SeeAllShoutsButtonFooter:
            return NSIndexPath(forItem: 5, inSection: 0)
        }
    }
    
    var kind: ProfileCollectionViewSupplementaryViewKind {
        switch self {
        case .Cover:
            return ProfileCollectionViewSupplementaryViewKind.Cover
        case .Info:
            return ProfileCollectionViewSupplementaryViewKind.Info
        case .PagesSectionHeader, .ShoutsSectionHeader:
            return ProfileCollectionViewSupplementaryViewKind.SectionHeader
        case .CreatePageButtonFooter, .SeeAllShoutsButtonFooter:
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