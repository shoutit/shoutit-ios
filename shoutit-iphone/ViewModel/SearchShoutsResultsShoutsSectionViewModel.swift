//
//  SearchShoutsResultsShoutsSectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

extension SearchShoutsResultsViewModel {
    
    final class ShoutsSection: PagedShoutsViewModel {
        
        unowned var parent: SearchShoutsResultsViewModel
        fileprivate(set) var pager: NumberedPagePager<ShoutCellViewModel, Shout>!
        
        var filtersState: FiltersState? {
            return parent.filtersState
        }
        
        init(parent: SearchShoutsResultsViewModel) {
            self.parent = parent
            self.pager = NumberedPagePager(itemToCellViewModelBlock: {ShoutCellViewModel(shout: $0)},
                                           cellViewModelToItemBlock: {$0.shout!},
                                           fetchItemObservableFactory: {self.fetchShoutsAtPage($0)},
                                           showAds: true
            )
        }
        
        // MARK: - To display
        
        func sectionTitle() -> String {
            if let searchPhrase = parent.searchPhrase {
                return String.localizedStringWithFormat(NSLocalizedString("Results for '%@'", comment: "Search results for search phrase section header"), searchPhrase)
            } else if case .categoryShouts(let category) = parent.context {
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
            case .profileShouts, .tagShouts:
                return false
            default:
                return true
            }
        }
        
        // MARK: Fetch
        
        func fetchShoutsAtPage(_ page: Int) -> Observable<PagedResults<Shout>> {
            let phrase = parent.searchPhrase
            let context = parent.context
            var params: FilteredShoutsParams
            switch context {
            case .general:
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              currentUserLocation: Account.sharedInstance.user?.location,
                                              skipLocation: false)
            case .discoverShouts(let item):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              discoverId: item.id,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              currentUserLocation: Account.sharedInstance.user?.location,
                                              skipLocation: false)
            case .profileShouts(let profile):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              username: profile.username,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              currentUserLocation: Account.sharedInstance.user?.location,
                                              skipLocation: false)
            case .tagShouts(let tag):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              tag: tag.slug,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              currentUserLocation: Account.sharedInstance.user?.location,
                                              skipLocation: false)
            case .categoryShouts(let category):
                params = FilteredShoutsParams(searchPhrase: phrase,
                                              page: page,
                                              pageSize: pageSize,
                                              category: category.slug,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              currentUserLocation: Account.sharedInstance.user?.location,
                                              skipLocation: false)
            }
            
            applyParamsToFilterParamsIfAny(&params)
            return APIShoutsService.listShoutsWithParams(params)
        }
    }
}
