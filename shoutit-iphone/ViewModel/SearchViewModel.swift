//
//  SearchViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class SearchViewModel {
    
    enum SearchState: Equatable {
        case inactive
        case active
        case typing(phrase: String)
    }
    
    enum SegmentedControlState: Equatable {
        
        enum Option {
            case shouts
            case users
        }
        case hidden(option: Option)
        case shown(option: Option)
    }
    
    // consts
    let minimumNumberOfCharactersForAutocompletion = 2
    lazy fileprivate var archivePath: String = {
        let directory = Account.sharedInstance.userDirectory
        let directoryURL = URL(fileURLWithPath: directory).appendingPathComponent("recent_searches.data")
        return directoryURL.path
    }()
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    fileprivate var requestDisposeBag = DisposeBag()
    
    // state
    let context: SearchContext
    var searchState: Variable<SearchState>
    var segmentedControlState: Variable<SegmentedControlState>
    var sectionViewModel: Variable<SearchSectionViewModel>
    
    // recents
    lazy var recentSearches: Set<String> = {[unowned self] in
        return NSKeyedUnarchiver.unarchiveObject(withFile: self.archivePath) as? Set<String> ?? Set()
    }()
    
    init(context: SearchContext) {
        self.context = context
        self.searchState = Variable(.inactive)
        self.segmentedControlState = Variable(.hidden(option: .shouts))
        self.sectionViewModel = Variable(.loadingPlaceholder)
        setupRX()
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        
        // dispose current requestes
        requestDisposeBag = DisposeBag()
        
        switch (context, searchState.value, segmentedControlState.value) {
        case (_, _, .shown(option: .users)):
            setSectionViewModelWithUsersPlaceholder()
        case (_, .typing(let phrase), .shown(option: .shouts)):
            loadSuggestionsForPhrase(phrase)
        case (_, .typing(let phrase), .hidden):
            loadSuggestionsForPhrase(phrase)
        case (_, .active, .hidden):
            setSectionViewModelWithEmptyScreen()
        // Active
        case (.general, .active, .shown(option: .shouts)):
            setSectionViewModelWithRecentSearches()
        case (.profileShouts, .active, .shown(option: .shouts)):
            setSectionViewModelWithEmptyScreen()
        case (.tagShouts, .active, .shown(option: .shouts)):
            setSectionViewModelWithEmptyScreen()
        case (.categoryShouts, .active, .shown(option: .shouts)):
            setSectionViewModelWithEmptyScreen()
        case (.discoverShouts, .active, .shown(option: .shouts)):
            setSectionViewModelWithEmptyScreen()
        // Inactive
        case (.general, .inactive, _):
            fetchCategories()
        case (.profileShouts, .inactive, _):
            setSectionViewModelWithEmptyScreen()
        case (.tagShouts, .inactive, _):
            setSectionViewModelWithEmptyScreen()
        case (.categoryShouts, .inactive, _):
            setSectionViewModelWithEmptyScreen()
        case (.discoverShouts, .inactive, _):
            setSectionViewModelWithEmptyScreen()
        default:
            assertionFailure()
            break
        }
    }
    
    func savePhraseToRecentSearchesIfApplicable(_ phrase: String) {
        if case .shown(option: .users) = segmentedControlState.value {
            return
        }
        recentSearches.insert(phrase)
        saveRecentSearches()
        reloadContent()
    }
    
    func removeRecentSearchPhrase(_ phrase: String) {
        recentSearches.remove(phrase)
        saveRecentSearches()
        reloadContent()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
        reloadContent()
    }
    
    // MARK: - Getter methods
    
    func searchBarPlaceholder() -> String {
        switch context {
        case .general:
            return NSLocalizedString("Search Shoutit", comment: "Search text field placeholder")
        case .discoverShouts(let item):
            return String.localizedStringWithFormat(NSLocalizedString("Search in %@ shouts", comment: "Search text field placeholder"), item.title)
        case .profileShouts(let profile):
            return String.localizedStringWithFormat(NSLocalizedString("Search in %@ shouts", comment: "Search text field placeholder"), profile.name)
        case .tagShouts(let tag):
            return String.localizedStringWithFormat(NSLocalizedString("Search in %@ shouts", comment: "Search text field placeholder"), tag.name)
        case .categoryShouts(let category):
            return String.localizedStringWithFormat(NSLocalizedString("Search in %@ shouts", comment: "Search text field placeholder"), category.name)
        }
    }
    
    // MARK: - Initial setup
    
    fileprivate func setupRX() {
        
        searchState
            .asObservable()
            .distinctUntilChanged()
            .subscribeNext {[unowned self] (searchState) in
                switch searchState {
                case .active, .typing:
                    if case (.general, .hidden(let option)) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .shown(option: option)
                    } else {
                        self.reloadContent()
                    }
                case .inactive:
                    if case (.general, .shown(let option)) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .hidden(option: option)
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        segmentedControlState
            .asObservable()
            .distinctUntilChanged()
            .subscribeNext {[weak self] (_) in
                self?.reloadContent()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Hydrate models
    
    fileprivate func fetchCategories() {
        
        APIShoutsService.listCategories()
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let categories):
                    self?.setSectionViewModelWithCategories(categories)
                case .Error(let error):
                    self?.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: error.sh_message, image: nil)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    fileprivate func loadSuggestionsForPhrase(_ phrase: String) {
        let params: AutocompletionParams
        if case SearchContext.categoryShouts(let category) = context {
            params = AutocompletionParams(phrase: phrase, categoryName: category.name, country: Account.sharedInstance.user?.location.country, useLocaleBasedCountryCodeWhenNil: true)
        } else {
            params = AutocompletionParams(phrase: phrase, categoryName: nil, country: Account.sharedInstance.user?.location.country, useLocaleBasedCountryCodeWhenNil: true)
        }
        APIShoutsService.getAutocompletionWithParams(params)
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let autocompletions):
                    self?.setSectionsViewModelWithAutocompletion(autocompletions)
                case .Error(let error):
                    self?.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: error.sh_message, image: nil)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    // MARK: - Create cell view models
    
    fileprivate func setSectionViewModelWithCategories(_ categories: [ShoutitKit.Category]) {
        
        if categories.count == 0 {
            let message = NSLocalizedString("No categores are available", comment: "")
            self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: message, image: nil)
        } else {
            let header = SearchSectionViewModel.HeaderType.titleCentered(title: NSLocalizedString("Categories", comment: "Main search screen categories header"))
            let cells = categories.map{SearchCategoryCellViewModel(category: $0)}
            self.sectionViewModel.value = SearchSectionViewModel.categories(cells: cells, header: header)
        }
    }
    
    fileprivate func setSectionViewModelWithEmptyScreen() {
        self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: nil, image: nil)
    }
    
    fileprivate func setSectionViewModelWithRecentSearches() {
        
        let searches = self.recentSearches
        if searches.count == 0 {
            setSectionViewModelWithEmptyScreen()
        } else {
            let header = SearchSectionViewModel.HeaderType.titleAlignedLeftWithButton(title: NSLocalizedString("Recent searches", comment: "Recent searches header"), buttonTitle: NSLocalizedString("CLEAR", comment: "recent searches clear button title"))
            let cells = searches.map{SearchSuggestionCellViewModel.recentSearch(phrase: $0)}
            self.sectionViewModel.value = SearchSectionViewModel.suggestions(cells: cells, header: header)
        }
    }
    
    fileprivate func setSectionsViewModelWithAutocompletion(_ autocompletionTerms: [AutocompletionTerm]) {
        if autocompletionTerms.count == 0 {
            setSectionViewModelWithEmptyScreen()
        } else {
            let header = SearchSectionViewModel.HeaderType.none
            let cells = autocompletionTerms.map{SearchSuggestionCellViewModel.apiSuggestion(phrase: $0.term)}
            self.sectionViewModel.value = SearchSectionViewModel.suggestions(cells: cells, header: header)
        }
    }
    
    fileprivate func setSectionViewModelWithUsersPlaceholder() {
        self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: NSLocalizedString("Search Users", comment: "Search users placeholder"), image: UIImage.searchUsersPlaceholder())
    }
    
    // MARK: - Compose requests
    
    // MARK: - Helpers
    
    fileprivate func saveRecentSearches() {
        NSKeyedArchiver.archiveRootObject(recentSearches, toFile: archivePath)
    }
}

func ==(lhs: SearchViewModel.SearchState, rhs: SearchViewModel.SearchState) -> Bool {
    switch (lhs, rhs) {
    case (.inactive, .inactive):
        return true
    case (.active, .active):
        return true
    case (.typing(let l), .typing(let r)):
        return l == r
    default:
        return false
    }
}

func ==(lhs: SearchViewModel.SegmentedControlState, rhs: SearchViewModel.SegmentedControlState) -> Bool {
    switch (lhs, rhs) {
    case (.shown(let l), .shown(let r)):
        return l == r
    case (.hidden(let l), .hidden(let r)):
        return l == r
    default:
        return false
    }
}
