//
//  FiltersCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum FiltersCellViewModel {
    
    enum DistanceRestrictionFilterOption {
        case Distance(kilometers: Int)
        case EntireCountry
        
        var title: String {
            switch self {
            case .Distance(let kilometers):
                return "\(kilometers) km"
            case .EntireCountry:
                return NSLocalizedString("Entire country", comment: "")
            }
        }
    }
    
    case ShoutTypeChoice(shoutType: ShoutType?)
    case SortTypeChoice(sortType: SortType?, loaded: (Void -> Bool))
    case CategoryChoice(category: Category?, enabled: Bool, loaded: (Void -> Bool))
    case PriceRestriction(from: Int?, to: Int?)
    case LocationChoice(location: Address?)
    case DistanceRestriction(distanceOption: DistanceRestrictionFilterOption)
    case FilterValueChoice(filter: Filter, selectedValues: [FilterValue])
    
    func buttonTitle() -> String? {
        switch self {
        case .ShoutTypeChoice(let shoutType):
            if let type = shoutType {
                return type.title()
            }
            return NSLocalizedString("All", comment: "All shout types - filter button title")
        case .SortTypeChoice(let sortType, _):
            return sortType?.name
        case .CategoryChoice(let category, _, _):
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
            return distanceOption.title
        case .FilterValueChoice(_, let values):
            return values.map{$0.name}.joinWithSeparator(", ")
        }
    }
}

extension FiltersCellViewModel.DistanceRestrictionFilterOption: Equatable {}

func ==(lhs: FiltersCellViewModel.DistanceRestrictionFilterOption, rhs: FiltersCellViewModel.DistanceRestrictionFilterOption) -> Bool {
    switch (lhs, rhs) {
    case (.EntireCountry, .EntireCountry):
        return true
    case (.Distance(let lhsDistance), .Distance(let rhsDistance)):
        return lhsDistance == rhsDistance
    default:
        return false
    }
}
