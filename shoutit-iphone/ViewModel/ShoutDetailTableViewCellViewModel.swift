//
//  ShoutDetailTableViewCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum ShoutDetailTableViewCellViewModel {
    case sectionHeader(title: String)
    case description(description: String)
    case keyValue(rowInSection: Int, sectionRowsCount: Int, key: String, value: String, imageName: String?, filter: Filter?, tag: ShoutitKit.Category?)
    case regular(rowInSection: Int, sectionRowsCount: Int, title: String)
    case button(title: String, type: ShoutDetailTableViewCellButtonType)
    case otherShouts
    case relatedShouts
    
    var reuseIdentifier: String {
        switch self {
        case .sectionHeader:
            return "SectionHeader"
        case .description:
            return "Description"
        case .keyValue:
            return "KeyValue"
        case .regular:
            return "Regular"
        case .button:
            return "Button"
        case .otherShouts:
            return "OtherShouts"
        case .relatedShouts:
            return "RelatedShouts"
        }
    }
}

enum ShoutDetailTableViewCellButtonType {
    case policies
    case visitProfile
}
