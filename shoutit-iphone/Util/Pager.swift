//
//  Pager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import Argo

class Pager<CellViewModelType, ItemType: Decodable where ItemType.DecodedType == ItemType> {
    
    static var pageSize: Int {
        return 20
    }
    private let disposeBag: DisposeBag = DisposeBag()
    private var requestDisposeBag: DisposeBag = DisposeBag()
    private(set) var state: Variable<PagedViewModelState<CellViewModelType>> = Variable(.Idle)
    
    var fetchItemObservableFactory: (Int -> Observable<PagedResults<ItemType>>)
    var itemTransformationBlock: (ItemType -> CellViewModelType)
    
    init(itemTransformationBlock: ItemType -> CellViewModelType, fetchItemObservableFactory: (Int -> Observable<PagedResults<ItemType>>)) {
        self.itemTransformationBlock = itemTransformationBlock
        self.fetchItemObservableFactory = fetchItemObservableFactory
    }
    
    func reloadContent() {
        state.value = .Loading
        fetchPage(1)
    }
    
    func reloadItemAtIndex(index: Int) {
        let page = index / Pager.pageSize + 1
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
        
        fetchItemObservableFactory(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let results):
                    self?.appendItems(results, forPage: page)
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
        fetchItemObservableFactory(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let results):
                    self?.reloadItems(results, atPage: page)
                case .Error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .Error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    // MARK: - Helpers
    
    private func appendItems(results: PagedResults<ItemType>, forPage page: Int) {
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            let fetchedProfiles = results.results
            cells += fetchedProfiles.map{itemTransformationBlock($0)}
            if fetchedProfiles.count < Pager.pageSize || results.nextPath == nil {
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
        
        let cellViewModels = profiles.map{itemTransformationBlock($0)}
        if profiles.count < Pager.pageSize || results.nextPath == nil {
            state.value = .LoadedAllContent(cells: cellViewModels, page: page)
        } else {
            state.value = .Loaded(cells: cellViewModels, page: page)
        }
    }
    
    private func reloadItems(results: PagedResults<ItemType>, atPage page: Int) {
        
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
    
    private func swapCellViewModels(currentCellViewModels: [CellViewModelType], withProfiles profiles: [ItemType], atPage page: Int) -> [CellViewModelType] {
        
        let pageStartIndex = (page - 1) * Pager.pageSize
        let pageEndIndex = pageStartIndex + profiles.count
        let range: Range<Int> = pageStartIndex..<pageEndIndex
        let newModels = profiles.map{itemTransformationBlock($0)}
        
        var models = currentCellViewModels
        models.replaceRange(range, with: newModels)
        return models
    }
}
