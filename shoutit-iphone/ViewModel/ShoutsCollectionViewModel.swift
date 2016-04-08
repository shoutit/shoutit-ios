//
//  ShoutsCollectionViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class ShoutsCollectionViewModel {
    
    enum Context {
        case ProfileShouts(user: Profile)
        case RelatedShouts(shout: Shout)
        case TagShouts(tag: Tag)
        case DiscoverItemShouts(discoverItem: DiscoverItem)
    }
    
    // consts
    private let pageSize = 20
    let context: Context
    
    // state
    private(set) var filterParams: FilteredShoutsParams?
    private var requestDisposeBag = DisposeBag()
    private(set) var state: Variable<PagedViewModelState<ShoutCellViewModel>> = Variable(.Idle)
    
    // data
    private(set) var numberOfResults: Int = 0
    
    init(context: Context) {
        self.context = context
    }
    
    func reloadContent() {
        state.value = .Loading
        fetchPage(1)
    }
    
    func applyFilters(filterParams: FilteredShoutsParams) {
        self.filterParams = filterParams
        reloadContent()
    }
    
    // MARK - Actions
    
    func fetchNextPage() {
        if case .LoadedAllContent = state.value { return }
        guard case .Loaded(let cells, let page) = state.value else { return }
        let pageToLoad = page + 1
        self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
    
    // MARK: - To display
    
    func sectionTitle() -> String {
        switch context {
        case .ProfileShouts(let user):
            return NSLocalizedString("\(user.firstName ?? user.name) Shouts", comment: "")
        case .RelatedShouts:
            return NSLocalizedString("Related Shouts", comment: "")
        case .TagShouts(let tag):
            return NSLocalizedString("\(tag.name) Shouts", comment: "")
        case .DiscoverItemShouts(let discoverItem):
            return discoverItem.title
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
        switch context {
        case .RelatedShouts(let shout):
            let params = RelatedShoutsParams(shout: shout, page: page, pageSize: pageSize, type: nil)
            return APIShoutsService.relatedShoutsWithParams(params)
        case .ProfileShouts(let profile):
            let params = FilteredShoutsParams(username: profile.username, page: page, pageSize: pageSize)
            return APIShoutsService.searchShoutsWithParams(params)
        case .TagShouts(let tag):
            let params = FilteredShoutsParams(tag: tag.name, page: page, pageSize: pageSize)
            return APIShoutsService.searchShoutsWithParams(params)
        case .DiscoverItemShouts(let discoverItem):
            let params = FilteredShoutsParams(discoverId: discoverItem.id, page: page, pageSize: pageSize)
            return APIShoutsService.searchShoutsWithParams(params)
        }
    }
    
    // MARK: - Helpers
    
    private func updateViewModelWithResult(result: PagedResults<Shout>, forPage page: Int) {
        
        numberOfResults = result.count ?? numberOfResults
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            cells += result.results.map{ShoutCellViewModel(shout: $0)}
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
        
        let cellViewModels = shouts.map{ShoutCellViewModel(shout: $0)}
        if shouts.count < pageSize || result.nextPath == nil {
            state.value = .LoadedAllContent(cells: cellViewModels, page: page)
        } else {
            state.value = .Loaded(cells: cellViewModels, page: page)
        }
    }
}
