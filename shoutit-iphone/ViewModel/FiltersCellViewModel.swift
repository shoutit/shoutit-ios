//
//  FiltersCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum FiltersCellViewModel {
    
    enum ShoutTypeFilterOption {
        case All
        case Specific(shoutType: ShoutType)
    }
    
    enum DistanceRestrictionFilterOption {
        case Distance(kilometers: Int)
        case EntireCountry
    }
    
    case ShoutTypeChoice(shoutType: ShoutTypeFilterOption)
    case CategoryChoice(category: Category?)
    case PriceRestriction(from: Int?, to: Int?)
    case LocationChoice(location: Address?)
    case DistanceRestriction(kilometers: DistanceRestrictionFilterOption)
    case FilterValueChoice(filter: Filter)
    
    static func distanceRestrictionOptions() -> [DistanceRestrictionFilterOption] {
        return [
            .Distance(kilometers: 1)
        ]
    }
}
