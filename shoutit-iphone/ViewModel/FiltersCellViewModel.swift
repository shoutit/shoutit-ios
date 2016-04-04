//
//  FiltersCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum FiltersCellViewModel {
    
    enum ShoutTypeFilter {
        case All
        case Specific(shoutType: ShoutType)
    }
    
    case ShoutTypeChoice(shoutType: ShoutTypeFilter)
    case CategoryChoice(category: Category)
    case PriceRestriction(from: Int, to: Int)
    case LocationChoice(location: Address)
    case DistanceRestriction(kilometers: Int)
    case FilterValueChoice(filter: Filter)
}
