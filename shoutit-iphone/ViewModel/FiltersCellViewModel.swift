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
    
    enum SortTypeFilterOption {
        case Default
        case Specific(sortType: SortType)
    }
    
    enum DistanceRestrictionFilterOption {
        case Distance(kilometers: Int)
        case EntireCountry
    }
    
    case ShoutTypeChoice(shoutType: ShoutTypeFilterOption)
    case SortTypeChoice(sortType: SortTypeFilterOption)
    case CategoryChoice(category: Category?)
    case PriceRestriction(from: Int?, to: Int?)
    case LocationChoice(location: Address?)
    case DistanceRestriction(distanceOption: DistanceRestrictionFilterOption)
    case FilterValueChoice(filter: Filter)
    
    func buttonTitle() -> String? {
        switch self {
        case .ShoutTypeChoice(let shoutType):
            switch shoutType {
            case .All:
                return NSLocalizedString("All", comment: "All shout types - filter button title")
            case .Specific(let shoutType):
                return shoutType.title()
            }
        case .SortTypeChoice(let sortType):
            switch sortType {
            case .Default:
                return NSLocalizedString("Default", comment: "Default sort type - filter button title")
            case .Specific(let sortType):
                return sortType.name
            }
        case .CategoryChoice(let category):
            if let category = category {
                return category.name
            }
            return NSLocalizedString("All Categories", comment: "Default category - filter button title")
        case .PriceRestriction:
            return nil
        case .LocationChoice(let location):
            if let location = location {
                return location.address
            }
            return NSLocalizedString("Choose location", comment: "Displayed on filter button when no location is chosen")
        case .DistanceRestriction(let distanceOption):
            return nil
        case .FilterValueChoice(let filter):
            return nil
        }
    }
    
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
