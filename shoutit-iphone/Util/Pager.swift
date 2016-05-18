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

enum PagerError: ErrorType {
    case StateDoesNotAllowManipulation
    case IndexExceedsBounds
}

class Pager<PageIndexType: Equatable, CellViewModelType, ItemType: Decodable where ItemType.DecodedType == ItemType> {
    
    private(set) var requestDisposeBag: DisposeBag = DisposeBag()
    private(set) var state: Variable<PagedViewModelState<CellViewModelType, PageIndexType, ItemType>> = Variable(.Idle)
    private(set) var numberOfResults: Int?
    
    let firstPageIndex: PageIndexType
    
    let itemToCellViewModelBlock: (ItemType -> CellViewModelType)
    let cellViewModelToItemBlock: (CellViewModelType -> ItemType)
    let fetchItemObservableFactory: (PageIndexType -> Observable<PagedResults<ItemType>>)
    let nextPageComputerBlock: ((PageIndexType, PagedResults<ItemType>) -> PageIndexType)
    let lastPageDidLoadExaminationBlock: (PagedResults<ItemType> -> Bool)
    var itemExclusionRule: (ItemType -> Bool)? // return true if item should be excluded
    
    init(itemToCellViewModelBlock: ItemType -> CellViewModelType,
         cellViewModelToItemBlock: CellViewModelType -> ItemType,
         fetchItemObservableFactory: (PageIndexType -> Observable<PagedResults<ItemType>>),
         nextPageComputerBlock: ((PageIndexType, PagedResults<ItemType>) -> PageIndexType),
         lastPageDidLoadExaminationBlock: (PagedResults<ItemType> -> Bool),
         firstPageIndex: PageIndexType
        )
    {
        self.itemToCellViewModelBlock = itemToCellViewModelBlock
        self.cellViewModelToItemBlock = cellViewModelToItemBlock
        self.fetchItemObservableFactory = fetchItemObservableFactory
        self.nextPageComputerBlock = nextPageComputerBlock
        self.lastPageDidLoadExaminationBlock = lastPageDidLoadExaminationBlock
        self.firstPageIndex = firstPageIndex
    }
    
    func loadContent() {
        state.value = .Loading
        fetchPage(firstPageIndex)
    }
    
    func refreshContent() {
        switch state.value {
        case let .Loaded(cells, page, _):
            state.value = .Refreshing(cells: cells, page: page)
            fetchPage(firstPageIndex)
        case let .LoadedAllContent(cells, page):
            state.value = .Refreshing(cells: cells, page: page)
            fetchPage(firstPageIndex)
        case let .LoadingMore(cells, currentPage, _):
            state.value = .Refreshing(cells: cells, page: currentPage)
            fetchPage(firstPageIndex)
        case .Refreshing:
            break
        default:
            loadContent()
        }
    }
    
    func fetchNextPage() {
        if case .LoadedAllContent = state.value { return }
        guard case .Loaded(let cells, let page, let results) = state.value else { return }
        let pageToLoad = nextPageComputerBlock(page, results)
        self.state.value = .LoadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
    
    func replaceItemAtIndex(index: Int, withItem item: ItemType) throws {
        switch state.value {
        case .Loaded(var cells, let page, let lastPageResults):
            guard index < cells.count else { throw PagerError.IndexExceedsBounds }
            cells[index] = itemToCellViewModelBlock(item)
            state.value = .Loaded(cells: cells, page: page, lastPageResults: lastPageResults)
        case .LoadedAllContent(var cells, let page):
            guard index < cells.count else { throw PagerError.IndexExceedsBounds }
            cells[index] = itemToCellViewModelBlock(item)
            state.value = .LoadedAllContent(cells: cells, page: page)
        default:
            throw PagerError.StateDoesNotAllowManipulation
        }
    }
    
    func findItemWithComparisonBlock(block: (ItemType -> Bool)) -> (Int, ItemType)? {
        guard let (cells, _) = try? getCellViewModelsForManipulation() else { return nil }
        for (index, cell) in cells.enumerate() {
            let item = cellViewModelToItemBlock(cell)
            if block(item) {
                return (index, item)
            }
        }
        return nil
    }
    
    // MARK: - Fetch
    
    private func fetchPage(page: PageIndexType) {
        
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
    
    // MARK: - Helpers
    
    private func appendItems(results: PagedResults<ItemType>, forPage page: PageIndexType) {
        
        numberOfResults = results.count ?? numberOfResults
        
        let items = results.results.filter{(item) -> Bool in
            if let rule = self.itemExclusionRule {
                return !rule(item)
            }
            return true
        }
        
        if case .LoadingMore(var cells, _, let loadingPage) = self.state.value where loadingPage == page {
            cells += items.map{itemToCellViewModelBlock($0)}
            if lastPageDidLoadExaminationBlock(results) {
                state.value = .LoadedAllContent(cells: cells, page: page)
            } else {
                state.value = .Loaded(cells: cells, page: page, lastPageResults: results)
            }
            return
        }
        
        assert(page == firstPageIndex)
        
        if items.count == 0 {
            state.value = .NoContent
            return
        }
        
        let cellViewModels = items.map{itemToCellViewModelBlock($0)}
        if lastPageDidLoadExaminationBlock(results) {
            state.value = .LoadedAllContent(cells: cellViewModels, page: page)
        } else {
            state.value = .Loaded(cells: cellViewModels, page: page, lastPageResults: results)
        }
    }
    
    private func getCellViewModelsForManipulation() throws -> ([CellViewModelType], PageIndexType) {
        switch state.value {
        case .Loaded(let cells, let page, _):
            return (cells, page)
        case .LoadedAllContent(let cells, let page):
            return (cells, page)
        default:
            throw PagerError.StateDoesNotAllowManipulation
        }
    }
}
