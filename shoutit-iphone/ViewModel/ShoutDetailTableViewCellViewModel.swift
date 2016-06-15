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
    case SectionHeader(title: String)
    case Description(description: String)
    case KeyValue(rowInSection: Int, sectionRowsCount: Int, key: String, value: String, imageName: String?, filter: Filter?, tag: ShoutitKit.Category?)
    case Regular(rowInSection: Int, sectionRowsCount: Int, title: String)
    case Button(title: String, type: ShoutDetailTableViewCellButtonType)
    case OtherShouts
    case RelatedShouts
    
    var reuseIdentifier: String {
        switch self {
        case .SectionHeader:
            return "SectionHeader"
        case .Description:
            return "Description"
        case .KeyValue:
            return "KeyValue"
        case .Regular:
            return "Regular"
        case .Button:
            return "Button"
        case .OtherShouts:
            return "OtherShouts"
        case .RelatedShouts:
            return "RelatedShouts"
        }
    }
}

enum ShoutDetailTableViewCellButtonType {
    case Policies
    case VisitProfile
}