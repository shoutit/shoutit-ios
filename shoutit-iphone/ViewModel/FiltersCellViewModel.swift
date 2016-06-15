//
//  FiltersCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum FiltersCellViewModel {
    
    case ShoutTypeChoice(shoutType: ShoutType?)
    case SortTypeChoice(sortType: SortType?, loaded: (Void -> Bool))
    case CategoryChoice(category: ShoutitKit.Category?, enabled: Bool, loaded: (Void -> Bool))
    case PriceRestriction(from: Int?, to: Int?)
    case LocationChoice(location: Address?)
    case DistanceRestriction(distanceOption: FiltersState.DistanceRestriction)
    case FilterValueChoice(filter: Filter, selectedValues: [FilterValue])
    
    func buttonTitle() -> String? {
        switch self {
        case .ShoutTypeChoice(let shoutType):
            if let type = shoutType {
                switch type {
                case .Offer: return NSLocalizedString("Only Offers", comment: "Filter shout type")
                case .Request: return NSLocalizedString("Only Requests", comment: "Filter shout type")
                }
            }
            return NSLocalizedString("Offers and Requests", comment: "Filter shout type")
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
            switch distanceOption {
            case .Distance(let kilometers):
                return "\(kilometers) km"
            case .EntireCountry:
                return NSLocalizedString("Entire country", comment: "")
            }
        case .FilterValueChoice(_, let values):
            return values.map{$0.name}.joinWithSeparator(", ")
        }
    }
}
