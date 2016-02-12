//
//  ProfileReusableViewKind.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionViewCellKind: String {
    case Pages = "ProfileCollectionViewCellKindPages"
    case Shouts = "ProfileCollectionViewCellKindShouts"
}

enum ProfileCollectionViewSupplementaryViewKind: String {
    case Cover = "ProfileCollectionViewSupplementaryViewKindCover"
    case Info = "ProfileCollectionViewSupplementaryViewKindInfo"
    case SectionHeader = "ProfileCollectionViewSupplementaryViewKindSectionHeader"
}
