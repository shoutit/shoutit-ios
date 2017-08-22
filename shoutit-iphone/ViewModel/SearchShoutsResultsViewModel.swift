//
//  SearchShoutsResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class SearchShoutsResultsViewModel {
    
    let context: SearchContext
    let searchPhrase: String?
    
    fileprivate(set) var shoutsSection: ShoutsSection!
    fileprivate(set) var categoriesSection: CategoriesSection!
    fileprivate(set) var filtersState: FiltersState?
    
    init(searchPhrase: String?, inContext context: SearchContext) {
        self.searchPhrase = searchPhrase
        self.context = context
        self.shoutsSection = ShoutsSection(parent: self)
        self.categoriesSection = CategoriesSection(parent: self)
    }
    
    func reloadContent() {
        shoutsSection.reloadContent()
        categoriesSection.reloadContent()
    }
    
    func applyFilters(_ filtersState: FiltersState) {
        self.filtersState = filtersState
        reloadContent()
    }
    
    func adCellReuseIdentifier() -> String {
        return "adItemGridCell"
    }
    
    func getFiltersState() -> FiltersState {
        if let filtersState = filtersState {
            return filtersState
        }
        
        if case .categoryShouts(let category) = context {
            return FiltersState(category: (category, .disabled),
                                location: (Account.sharedInstance.user?.location, .enabled),
                                withinDistance: (.distance(kilometers: 20), .enabled))
        }
        
        return FiltersState(location: (Account.sharedInstance.user?.location, .enabled),
                            withinDistance: (.distance(kilometers: 20), .enabled))
    }
}
