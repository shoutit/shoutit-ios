//
//  FiltersViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 31.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class FiltersViewModel {
    
    
    
    private func basicCellViewModels() -> [FiltersCellViewModel] {
        let shoutTypeCellViewModel = FiltersCellViewModel.ShoutTypeChoice(shoutType: .All)
        let categoryCellViewModel = FiltersCellViewModel.CategoryChoice(category: nil)
        let priceConstraintCellViewModel = FiltersCellViewModel.PriceRestriction(from: nil, to: nil)
        let locationViewModel = FiltersCellViewModel.LocationChoice(location: Account.sharedInstance.user?.location)
        let distanceConstraintViewModel = FiltersCellViewModel.DistanceRestriction(distanceOption: .EntireCountry)
        return [shoutTypeCellViewModel,
                categoryCellViewModel,
                priceConstraintCellViewModel,
                locationViewModel,
                distanceConstraintViewModel]
    }
}
