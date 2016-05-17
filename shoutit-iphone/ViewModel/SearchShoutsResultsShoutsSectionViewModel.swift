//
//  SearchShoutsResultsShoutsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

extension SearchShoutsResultsViewModel {
    
    final class ShoutsSection: PagedShoutsViewModel {
        
        unowned var parent: SearchShoutsResultsViewModel
        private(set) var pager: NumberedPagePager<ShoutCellViewModel, Shout>!
        
        var filtersState: FiltersState? {
            return parent.filtersState
        }
        
        init(parent: SearchShoutsResultsViewModel) {
            self.parent = parent
            self.pager = NumberedPagePager(itemToCellViewModelBlock: {ShoutCellViewModel(shout: $0)},
                                           cellViewModelToItemBlock: {$0.shout},
                                           fetchItemObservableFactory: {self.fetchShoutsAtPage($0)}
            )
        }
        
        // MARK: - To display
        
        func sectionTitle() -> String {
            if let searchPhrase = parent.searchPhrase {
                return String.localizedStringWithFormat(NSLocalizedString("Results for '%@'", comment: "Search results for search phrase section header"), searchPhrase)
            } else if case .CategoryShouts(let category) = parent.context {
                return String.localizedStringWithFormat(NSLocalizedString("Results for '%@'", comment: ""), category.name)
            } else if case (let location?, _) = parent.getFiltersState().location {
                return String.localizedStringWithFormat(NSLocalizedString("Shouts in %@", comment: ""), location.city)
            } else {
                return NSLocalizedString("Results", comment: "Search results section header")
            }
        }
        
        func resultsCountString() -> String {
            return String.localizedStringWithFormat(NSLocalizedString("%d Shouts", comment: "Search results count string"), numberOfResults ?? 0)
        }
        
        func allowsFiltering() -> Bool {
            switch parent.context {
            case .ProfileShouts, .TagShouts:
                return false
            default:
                return true
            }
        }
        
        // MARK: Fetch
        
        func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>> {
            let phrase = parent.searchPhrase
            let context = parent.context
            var params: FilteredShoutsParams
            switch context {
            case .General:
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            case .DiscoverShouts(let item):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              discoverId: item.id,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            case .ProfileShouts(let profile):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              username: profile.username,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            case .TagShouts(let tag):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              tag: tag.name,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            case .CategoryShouts(let category):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              category: category.slug,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            }
            
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.searchShoutsWithParams(params)
        }
    }
}