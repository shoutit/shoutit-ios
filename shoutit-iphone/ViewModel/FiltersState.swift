//
//  FiltersState.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

struct FiltersState {
    
    enum DistanceRestriction {
        case Distance(kilometers: Int)
        case EntireCountry
    }
    
    enum Editing {
        case Enabled
        case Disabled
    }
    let shoutType: (ShoutType?, Editing)
    let sortType: (SortType?, Editing)
    let category: (ShoutitKit.Category?, Editing)
    let minimumPrice: (Int?, Editing)
    let maximumPrice: (Int?, Editing)
    let location: (Address?, Editing)
    let withinDistance: (DistanceRestriction?, Editing)
    let filters: [(Filter, [FilterValue])]?
    
    init(shoutType: (ShoutType?, Editing) = (nil, .Enabled),
         sortType: (SortType?, Editing) = (nil, .Enabled),
         category: (ShoutitKit.Category?, Editing) = (nil, .Enabled),
         minimumPrice: (Int?, Editing) = (nil, .Enabled),
         maximumPrice: (Int?, Editing) = (nil, .Enabled),
         location: (Address?, Editing) = (nil, .Enabled),
         withinDistance: (DistanceRestriction?, Editing) = (nil, .Enabled),
         filters: [(Filter, [FilterValue])]? = nil)
    {
        self.shoutType = shoutType
        self.sortType = sortType
        self.category = category
        self.minimumPrice = minimumPrice
        self.maximumPrice = maximumPrice
        self.location = location
        self.withinDistance = withinDistance
        self.filters = filters
    }
    
    func composeParams() -> FilteredShoutsParams {
        
        let distance: Int?
        let entireCountry: Bool
        
        switch withinDistance.0 {
        case .Some(.EntireCountry):
            entireCountry = true
            distance = nil
        case .Some(.Distance(let kilometers)):
            entireCountry = false
            distance = kilometers
        default:
            entireCountry = false
            distance = nil
        }
        
        return FilteredShoutsParams(country: location.0?.country,
                                    state: location.0?.state,
                                    city: location.0?.city,
                                    shoutType: shoutType.0,
                                    category: category.0?.slug,
                                    minimumPrice: minimumPrice.0 == nil ? nil : minimumPrice.0! * 100,
                                    maximumPrice: maximumPrice.0 == nil ? nil : maximumPrice.0! * 100,
                                    withinDistance: distance,
                                    entireCountry: entireCountry,
                                    sort: sortType.0,
                                    filters: filters,
                                    currentUserLocation: Account.sharedInstance.user?.location, skipLocation: false)
    }
}

extension FiltersState.DistanceRestriction: Equatable {}

func ==(lhs: FiltersState.DistanceRestriction, rhs: FiltersState.DistanceRestriction) -> Bool {
    switch (lhs, rhs) {
    case (.EntireCountry, .EntireCountry):
        return true
    case (.Distance(let lhsDistance), .Distance(let rhsDistance)):
        return lhsDistance == rhsDistance
    default:
        return false
    }
}
