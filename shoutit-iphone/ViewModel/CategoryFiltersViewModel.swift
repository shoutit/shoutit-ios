//
//  CategoryFiltersViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class CategoryFiltersViewModel {
    
    let filter: Filter
    var cellViewModels: [CategoryFiltersCellViewModel]
    
    init(filter: Filter, selectedValues: [FilterValue]) {
        assert(filter.values != nil)
        let filterValues = filter.values ?? []
        self.filter = filter
        self.cellViewModels = filterValues.map{CategoryFiltersCellViewModel(filterValue: $0, selected: selectedValues.contains($0))}
    }
    
    func selectedFilterValues() -> [FilterValue] {
        return cellViewModels.filter{$0.selected}.map{$0.filterValue}
    }
}
