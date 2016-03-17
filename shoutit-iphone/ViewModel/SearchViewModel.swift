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
    lazy var recentSearches: [String] = {[unowned self] in
        return NSKeyedUnarchiver.unarchiveObjectWithFile(self.archivePath) as? [String] ?? []
    }()
    
    init(context: SearchContext) {
        self.context = context
        self.searchState = Variable(.Inactive)
        self.segmentedControlState = Variable(.Hidden)
        self.sectionViewModel = Variable(.LoadingPlaceholder)
        setupRX()
    }
    
    deinit {
        NSKeyedArchiver.archiveRootObject(recentSearches, toFile: archivePath)
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        
        // dispose current requestes
        requestDisposeBag = DisposeBag()
        
        switch (context, searchState.value, segmentedControlState.value) {
        case (.General, .Inactive, _):
            fetchCategories()
        case (.General, .Active, .Shouts):
            setSectionViewModelWithRecentSearches()
        case (.General, _, .Users):
            setSectionViewModelWithUsersPlaceholder()
        case (.General, .Typing(let phrase), .Shouts):
            loadSuggestionsForPhrase(phrase)
        default:
            break
        }
    }
    
    func searchWithPhrase(phrase: String) {
        recentSearches.insert(phrase, atIndex: 0)
        reloadContent()
    }
    
    func removeRecentSearchPhrase(phrase: String) {
        recentSearches.removeElementIfExists(phrase)
        reloadContent()
    }
    
    func clearRecentSearches() {
        recentSearches = []
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
                    if case (.General, .Hidden) = (self.context, self.segmentedControlState.value) {
                        self.segmentedControlState.value = .Shouts
                    }
                    self.reloadContent()
                case .Inactive:
                    self.segmentedControlState.value = .Hidden
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
