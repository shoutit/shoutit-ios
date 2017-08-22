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
    
    case shoutTypeChoice(shoutType: ShoutType?)
    case sortTypeChoice(sortType: SortType?, loaded: ((Void) -> Bool))
    case categoryChoice(category: ShoutitKit.Category?, enabled: Bool, loaded: ((Void) -> Bool))
    case priceRestriction(from: Int?, to: Int?)
    case locationChoice(location: Address?)
    case distanceRestriction(distanceOption: FiltersState.DistanceRestriction)
    case filterValueChoice(filter: Filter, selectedValues: [FilterValue])
    
    func buttonTitle() -> String? {
        switch self {
        case .shoutTypeChoice(let shoutType):
            if let type = shoutType {
                switch type {
                case .Offer: return NSLocalizedString("Only Offers", comment: "Filter shout type")
                case .Request: return NSLocalizedString("Only Requests", comment: "Filter shout type")
                }
            }
            return NSLocalizedString("Offers and Requests", comment: "Filter shout type")
        case .sortTypeChoice(let sortType, _):
            return sortType?.name
        case .categoryChoice(let category, _, _):
            if let category = category {
                return category.name
            }
            return NSLocalizedString("All Categories", comment: "Default category - filter button title")
        case .priceRestriction:
            return nil
        case .locationChoice(let location):
            if let location = location {
                return location.address
            }
            return NSLocalizedString("Choose location", comment: "Displayed on filter button when no location is chosen")
        case .distanceRestriction(let distanceOption):
            switch distanceOption {
            case .distance(let kilometers):
                return "\(kilometers) km"
            case .entireCountry:
                return NSLocalizedString("Entire country", comment: "Default Range Search")
            }
        case .filterValueChoice(_, let values):
            return values.map{$0.name}.joined(separator: ", ")
        }
    }
}
