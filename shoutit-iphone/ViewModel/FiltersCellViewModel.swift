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
    case DistanceRestriction(distanceOption: DistanceRestrictionFilterOption)
    case FilterValueChoice(filter: Filter)
    
    static func distanceRestrictionOptions() -> [DistanceRestrictionFilterOption] {
        return [
            .Distance(kilometers: 1),
            .Distance(kilometers: 2),
            .Distance(kilometers: 3),
            .Distance(kilometers: 5),
            .Distance(kilometers: 7),
            .Distance(kilometers: 10),
            .Distance(kilometers: 15),
            .Distance(kilometers: 20),
            .Distance(kilometers: 30),
            .Distance(kilometers: 60),
            .Distance(kilometers: 100),
            .Distance(kilometers: 200),
            .Distance(kilometers: 300),
            .Distance(kilometers: 400),
            .Distance(kilometers: 500),
            .EntireCountry
        ]
    }
}
