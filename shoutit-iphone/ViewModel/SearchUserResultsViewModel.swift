//
//  SearchUserResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class SearchUserResultsViewModel {
    
    let searchPhrase: String
    
    // consts
    private let pageSize = 20
    
    // RX
    private let disposeBag = DisposeBag()
    private var requestDisposeBag = DisposeBag()
    private(set) var state: Variable<PagedViewModelState<SearchUserProfileCellViewModel>> = Variable(.Idle)
    
    init(searchPhrase: String) {
        self.searchPhrase = searchPhrase
    }
    
    // MARK: - Actions
    
    func reloadContent() {
        state.value = .Loading
        fetchPage(1)
    }
    
    func reloadItemAtIndex(index: Int) {
        let page = index / pageSize + 1
        reloadItemsAtPage(page)
    }
    
    func fetchNextPage() {
        if case .LoadedAllContent = state.value { return }
        guard case .Loaded(let cells, let page) = state.value else { return }
        let pageToLoad = page + 1
        self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
    
    // MARK: - Fetch
    
    private func fetchPage(page: Int) {
        
        requestDisposeBag = DisposeBag()
        
        fetchProfilesForPage(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let profiles):
                    self?.appendProfiles(profiles, forPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func reloadItemsAtPage(page: Int) {
        fetchProfilesForPage(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let profiles):
                    self?.reloadProfiles(profiles, atPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func fetchProfilesForPage(page: Int) -> Observable<[Profile]> {
        let params = SearchParams(phrase: searchPhrase, page: page, pageSize: pageSize)
        return APIProfileService.searchProfileWithParams(params)
    }
    
    // MARK: - Helpers
    
    private func appendProfiles(profiles: [Profile], forPage page: Int) {
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            cells += profiles.map{SearchUserProfileCellViewModel(profile: $0)}
            if cells.count < pageSize {
                state.value = .LoadedAllContent(cells: cells, page: page)
            } else {
                state.value = .Loaded(cells: cells, page: page)
            }
            return
        }
        
        assert(page == 1)
        
        if profiles.count == 0 {
            state.value = .NoContent
            return
        }
        
        state.value = .Loaded(cells: profiles.map{SearchUserProfileCellViewModel(profile: $0)}, page: page)
    }
    
    private func reloadProfiles(profiles: [Profile], atPage page: Int) {
        
        guard case .Loaded(var models, let numberOfPages) = state.value where numberOfPages >= page else {
            return
        }
        
        let pageStartIndex = (page - 1) * pageSize
        let pageEndIndex = pageStartIndex + profiles.count
        let range: Range<Int> = pageStartIndex..<pageEndIndex
        let newModels = profiles.map{SearchUserProfileCellViewModel(profile: $0)}
        print(models)
        models.replaceRange(range, with: newModels)
        print(models)
        
        state.value = .Loaded(cells: models, page: numberOfPages)
    }
}
