//
//  FiltersState.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 13.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

struct FiltersState {
    
    enum Editing {
        case Enabled
        case Disabled
    }
    let shoutType: (ShoutType?, Editing)
    let sortType: (SortType?, Editing)
    let category: (Category?, Editing)
    let minimumPrice: (Int?, Editing)
    let maximumPrice: (Int?, Editing)
    let location: (Address?, Editing)
    let withinDistance: (Int?, Editing)
    let filters: [(Filter, [FilterValue])]?
    
    init(shoutType: (ShoutType?, Editing) = (nil, .Enabled),
         sortType: (SortType?, Editing) = (nil, .Enabled),
         category: (Category?, Editing) = (nil, .Enabled),
         minimumPrice: (Int?, Editing) = (nil, .Enabled),
         maximumPrice: (Int?, Editing) = (nil, .Enabled),
         location: (Address?, Editing) = (nil, .Enabled),
         withinDistance: (Int?, Editing) = (nil, .Enabled),
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
        return FilteredShoutsParams(country: location.0?.country,
                                    state: location.0?.state,
                                    city: location.0?.city,
                                    shoutType: shoutType.0,
                                    category: category.0?.slug,
                                    minimumPrice: minimumPrice.0 == nil ? nil : minimumPrice.0! * 100,
                                    maximumPrice: maximumPrice.0 == nil ? nil : maximumPrice.0! * 100,
                                    withinDistance: withinDistance.0,
                                    entireCountry: withinDistance.0 == nil,
                                    sort: sortType.0,
                                    filters: filters)
    }
}
