//
//  SearchUserResultsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class SearchUserResultsViewModel {
    
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
                case .Next(let results):
                    self?.appendProfiles(results, forPage: page)
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
                case .Next(let results):
                    self?.reloadProfiles(results, atPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    private func fetchProfilesForPage(page: Int) -> Observable<PagedResults<Profile>> {
        let params = SearchParams(phrase: searchPhrase, page: page, pageSize: pageSize)
        return APIProfileService.searchProfileWithParams(params)
    }
    
    // MARK: - Helpers
    
    private func appendProfiles(results: PagedResults<Profile>, forPage page: Int) {
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            let fetchedProfiles = results.results
            cells += fetchedProfiles.map{SearchUserProfileCellViewModel(profile: $0)}
            if fetchedProfiles.count < pageSize || results.nextPath == nil {
                state.value = .LoadedAllContent(cells: cells, page: page)
            } else {
                state.value = .Loaded(cells: cells, page: page)
            }
            return
        }
        
        assert(page == 1)
        
        let profiles = results.results
        
        if profiles.count == 0 {
            state.value = .NoContent
            return
        }
        
        let cellViewModels = profiles.map{SearchUserProfileCellViewModel(profile: $0)}
        if profiles.count < pageSize || results.nextPath == nil {
            state.value = .LoadedAllContent(cells: cellViewModels, page: page)
        } else {
            state.value = .Loaded(cells: cellViewModels, page: page)
        }
    }
    
    private func reloadProfiles(results: PagedResults<Profile>, atPage page: Int) {
        
        switch state.value {
        case .Loaded(let models, let numberOfPages):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .Loaded(cells: swappedModels, page: numberOfPages)
        case .LoadedAllContent(let models, let numberOfPages):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .LoadedAllContent(cells: swappedModels, page: numberOfPages)
        default:
            break
        }
    }
    
    private func swapCellViewModels(currentCellViewModels: [SearchUserProfileCellViewModel], withProfiles profiles: [Profile], atPage page: Int) -> [SearchUserProfileCellViewModel] {
        
        let pageStartIndex = (page - 1) * pageSize
        let pageEndIndex = pageStartIndex + profiles.count
        let range: Range<Int> = pageStartIndex..<pageEndIndex
        let newModels = profiles.map{SearchUserProfileCellViewModel(profile: $0)}
        
        var models = currentCellViewModels
        models.replaceRange(range, with: newModels)
        return models
    }
}
