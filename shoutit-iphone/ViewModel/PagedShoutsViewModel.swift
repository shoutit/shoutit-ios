//
//  PagedShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

protocol PagedShoutsViewModel: class {
    
    var filtersState: FiltersState? {get}
    var requestDisposeBag: DisposeBag {get set}
    var state: Variable<PagedViewModelState<ShoutCellViewModel>> {get}
    var numberOfResults: Int {get set}
    
    func reloadContent() -> Void
    func fetchShoutsAtPage(page: Int) -> Observable<PagedResults<Shout>>
}

extension PagedShoutsViewModel {
    
    var pageSize: Int {
        return 20
    }
    
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
    
    func applyParamsToFilterParamsIfAny(inout params: FilteredShoutsParams) {
        if let filtersState = filtersState {
            let filterParams = filtersState.composeParams()
            params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
        }
    }
}

private extension PagedShoutsViewModel {
    
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
