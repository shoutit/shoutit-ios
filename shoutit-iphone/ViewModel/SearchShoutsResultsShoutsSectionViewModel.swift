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
    
    class ShoutsSection {
        
        // consta
        private let pageSize = 20
        
        unowned var parent: SearchShoutsResultsViewModel
        
        private var requestDisposeBag = DisposeBag()
        private(set) var state: Variable<PagedViewModelState<SearchShoutsResultsShoutCellViewModel>> = Variable(.Idle)
        
        // data
        private(set) var numberOfResults: Int = 0
        
        init(parent: SearchShoutsResultsViewModel) {
            self.parent = parent
        }
        
        // MARK - Actions
        
        func reloadContent() {
            state.value = .Loading
            fetchPage(1)
        }
        
        func fetchNextPage() {
            if case .LoadedAllContent = state.value { return }
            guard case .Loaded(let cells, let page) = state.value else { return }
            let pageToLoad = page + 1
            self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
            fetchPage(pageToLoad)
        }
        
        // MARK: - To display
        
        func sectionTitle() -> String {
            if let searchPhrase = parent.searchPhrase {
                return NSLocalizedString("Results for '\(searchPhrase)'", comment: "Search results for search phrase section header")
            } else if case .CategoryShouts(let category) = parent.context {
                return NSLocalizedString("Results for \(category.name)", comment: "Search results for category section header")
            } else if let city = parent.filterParams?.city ?? Account.sharedInstance.user?.location.city {
                return NSLocalizedString("Shouts in \(city)", comment: "Browse section header")
            } else {
                return NSLocalizedString("Results", comment: "Search results section header")
            }
        }
        
        func resultsCountString() -> String {
            return NSLocalizedString("\(numberOfResults) Shouts", comment: "Search results count string")
        }
        
        // MARK: Fetch
        
        private func fetchPage(page: Int) {
            
            requestDisposeBag = DisposeBag()
            
            fetchShoutsAtPage(page)
                .subscribe {[weak self] (event) in
                    switch event {
                    case .Next(let results):
                        self?.updateViewModelWithResult(results, forPage: page)
                    case .Error(let error):
                        print(error)
                        self?.state.value = .Error(error)
                    default:
                        break
                    }
                }
                .addDisposableTo(requestDisposeBag)
        }
        
        private func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>> {
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
                                              tag: category.slug,
                                              page: page,
                                              pageSize: pageSize,
                                              useLocaleBasedCountryCodeWhenNil: true,
                                              includeCurrentUserLocation: true)
            }
            
            if let filterParams = parent.filterParams {
                params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
            }
            
            return APIShoutsService.searchShoutsWithParams(params)
        }
        
        // MARK: - Helpers
        
        private func updateViewModelWithResult(result: PagedResults<Shout>, forPage page: Int) {
            
            numberOfResults = result.count ?? numberOfResults
            
            if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
                cells += result.results.map{SearchShoutsResultsShoutCellViewModel(shout: $0)}
                if cells.count < pageSize || result.nextPath == nil {
                    state.value = .LoadedAllContent(cells: cells, page: page)
                } else {
                    state.value = .Loaded(cells: cells, page: page)
                }
                return
            }
            
            assert(page == 1)
            
            let shouts = result.results
            if shouts.count == 0 {
                state.value = .NoContent
            }
            
            let cellViewModels = shouts.map{SearchShoutsResultsShoutCellViewModel(shout: $0)}
            if shouts.count < pageSize || result.nextPath == nil {
                state.value = .LoadedAllContent(cells: cellViewModels, page: page)
            } else {
                state.value = .Loaded(cells: cellViewModels, page: page)
            }
        }
    }
}