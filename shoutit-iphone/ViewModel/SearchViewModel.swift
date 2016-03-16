//
//  SearchViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class SearchViewModel {
    
    enum SearchState: Equatable {
        case Inactive
        case Active
        case Typing(phrase: String)
    }
    
    enum SegmentedControlState {
        case Hidden
        case Shouts
        case Users
    }
    
    // RX
    private let disposeBag = DisposeBag()
    private var requestDisposeBag = DisposeBag()
    
    // state
    let context: SearchContext
    var searchState: Variable<SearchState>
    var segmentedControlState: Variable<SegmentedControlState>
    var sectionViewModel: Variable<SearchSectionViewModel>
    
    init(context: SearchContext) {
        self.context = context
        self.searchState = Variable(.Inactive)
        self.segmentedControlState = Variable(.Hidden)
        self.sectionViewModel = Variable(.LoadingPlaceholder)
        setupRX()
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        
        // dispose current requestes
        requestDisposeBag = DisposeBag()
        
        switch (context, searchState.value) {
        case (.General, .Inactive):
            fetchCategories()
        default:
            break
        }
    }
    
    // MARK: - Getter methods
    
    func searchBarPlaceholder() -> String {
        switch context {
        case .General:
            return NSLocalizedString("Search Shoutit", comment: "Search text field placeholder")
        case .DiscoverShouts(let item):
            return NSLocalizedString("Search in \(item.title) shouts", comment: "Search text field placeholder")
        case .ProfileShouts(let profile):
            return NSLocalizedString("Search in \(profile.name) shouts", comment: "Search text field placeholder")
        case .TagShouts(let tag):
            return NSLocalizedString("Search in \(tag.name) shouts", comment: "Search text field placeholder")
        }
    }
    
    // MARK: - Initial setup
    
    private func setupRX() {
        
        searchState
            .asObservable()
            .distinctUntilChanged()
            .subscribeNext {[unowned self] (searchState) in
                switch searchState {
                case .Active:
                    if case (.General, .Hidden) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .Shouts
                    }
                case .Inactive:
                    self.segmentedControlState.value = .Hidden
                case .Typing(let phrase):
                    if case (.General, .Hidden) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .Shouts
                    }
                    self.fetchShoutsForNewPhrase(phrase)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Hydrate models
    
    private func fetchCategories() {
        
        APIShoutsService.listCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let categories):
                    self?.setSectionViewModelWithCategories(categories)
                case .Error(let error):
                    self?.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: error.sh_message, image: nil)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func fetchShoutsForNewPhrase(phrase: String) {
        
    }
    
    // MARK: - Create cell view models
    
    private func setSectionViewModelWithCategories(categories: [Category]) {
        
        if categories.count == 0 {
            let message = NSLocalizedString("No categores are available", comment: "")
            self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: message, image: nil)
        } else {
            let header = SearchSectionViewModel.HeaderType.TitleCentered(title: NSLocalizedString("Categories", comment: "Main search screen categories header"))
            let cells = categories.map{SearchCategoryCellViewModel(category: $0)}
            self.sectionViewModel.value = SearchSectionViewModel.Categories(cells: cells, header: header)
        }
    }
    
    // MARK: - Compose requests
    
    private func fetchShoutsWithSearchPhrase(phrase: String, context: SearchContext, page: Int) -> Observable<[Shout]> {
        let pageSize = 20
        let params: FilteredShoutsParams
        switch context {
        case .General:
            params = FilteredShoutsParams(searchPhrase: phrase, page: page, pageSize: pageSize)
        case .DiscoverShouts(let item):
            params = FilteredShoutsParams(searchPhrase: phrase, discoverId: item.id, page: page, pageSize: pageSize)
        case .ProfileShouts(let profile):
            params = FilteredShoutsParams(searchPhrase: phrase, username: profile.username, page: page, pageSize: pageSize)
        case .TagShouts(let tag):
            params = FilteredShoutsParams(searchPhrase: phrase, tag: tag.name, page: page, pageSize: pageSize)
        }
        
        return APIShoutsService.listShoutsWithParams(params)
    }
}

func ==(lhs: SearchViewModel.SearchState, rhs: SearchViewModel.SearchState) -> Bool {
    switch (lhs, rhs) {
    case (.Inactive, .Inactive):
        return true
    case (.Active, .Active):
        return true
    case (.Typing(let l), .Typing(let r)):
        return l == r
    default:
        return false
    }
}
