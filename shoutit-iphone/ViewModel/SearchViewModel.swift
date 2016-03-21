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
    
    enum SegmentedControlState: Equatable {
        
        enum Option {
            case Shouts
            case Users
        }
        case Hidden(option: Option)
        case Shown(option: Option)
    }
    
    // consts
    lazy private var archivePath: String = {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let directoryURL = NSURL(fileURLWithPath: directory).URLByAppendingPathComponent("recent_searches.data")
        return directoryURL.path!
    }()
    
    // RX
    private let disposeBag = DisposeBag()
    private var requestDisposeBag = DisposeBag()
    
    // state
    let context: SearchContext
    var searchState: Variable<SearchState>
    var segmentedControlState: Variable<SegmentedControlState>
    var sectionViewModel: Variable<SearchSectionViewModel>
    
    // recents
    lazy var recentSearches: Set<String> = {[unowned self] in
        return NSKeyedUnarchiver.unarchiveObjectWithFile(self.archivePath) as? Set<String> ?? Set()
    }()
    
    init(context: SearchContext) {
        self.context = context
        self.searchState = Variable(.Inactive)
        self.segmentedControlState = Variable(.Hidden(option: .Shouts))
        self.sectionViewModel = Variable(.LoadingPlaceholder)
        setupRX()
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        
        // dispose current requestes
        requestDisposeBag = DisposeBag()
        
        switch (context, searchState.value, segmentedControlState.value) {
        case (.General, .Inactive, _):
            fetchCategories()
        case (.General, .Active, .Shown(option: .Shouts)):
            setSectionViewModelWithRecentSearches()
        case (.General, _, .Shown(option: .Users)):
            setSectionViewModelWithUsersPlaceholder()
        case (.General, .Typing(let phrase), .Shown(option: .Shouts)):
            loadSuggestionsForPhrase(phrase)
        default:
            break
        }
    }
    
    func savePhraseToRecentSearchesIfApplicable(phrase: String) {
        if case .Shown(option: .Users) = segmentedControlState.value {
            return
        }
        recentSearches.insert(phrase)
        saveRecentSearches()
        reloadContent()
    }
    
    func removeRecentSearchPhrase(phrase: String) {
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
                case .Active, .Typing:
                    if case (.General, .Hidden(let option)) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .Shown(option: option)
                    }
                    self.reloadContent()
                case .Inactive:
                    if case (.General, .Shown(let option)) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .Hidden(option: option)
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
    
    private func loadSuggestionsForPhrase(phrase: String) {
        
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
    
    private func setSectionViewModelWithRecentSearches() {
        
        let searches = self.recentSearches
        if searches.count == 0 {
            self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: nil, image: nil)
        } else {
            let header = SearchSectionViewModel.HeaderType.TitleAlignedLeftWithButton(title: NSLocalizedString("Recent searches", comment: "Recent searches header"), buttonTitle: NSLocalizedString("CLEAR", comment: "recent searches clear button title"))
            let cells = searches.map{SearchSuggestionCellViewModel.RecentSearch(phrase: $0)}
            self.sectionViewModel.value = SearchSectionViewModel.Suggestions(cells: cells, header: header)
        }
    }
    
    private func setSectionViewModelWithUsersPlaceholder() {
        self.sectionViewModel.value = SearchSectionViewModel.MessagePlaceholder(message: NSLocalizedString("Search Users", comment: "Search users placeholder"), image: UIImage.searchUsersPlaceholder())
    }
    
    // MARK: - Compose requests
    
    // MARK: - Helpers
    
    private func saveRecentSearches() {
        NSKeyedArchiver.archiveRootObject(recentSearches, toFile: archivePath)
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

func ==(lhs: SearchViewModel.SegmentedControlState, rhs: SearchViewModel.SegmentedControlState) -> Bool {
    switch (lhs, rhs) {
    case (.Shown(let l), .Shown(let r)):
        return l == r
    case (.Hidden(let l), .Hidden(let r)):
        return l == r
    default:
        return false
    }
}
