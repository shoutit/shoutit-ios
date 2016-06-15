//
//  NumberedPagePager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import Argo
import ShoutitKit

class NumberedPagePager<CellViewModelType, ItemType: Decodable where ItemType.DecodedType == ItemType>: Pager<Int, CellViewModelType, ItemType> {
    
    let pageSize: Int
    var cellViewModelsComparisonBlock: ((lhs: CellViewModelType, rhs: CellViewModelType) -> Bool)?
    
    init(
        itemToCellViewModelBlock: ItemType -> CellViewModelType,
        cellViewModelToItemBlock: CellViewModelType -> ItemType,
        fetchItemObservableFactory: (Int -> Observable<PagedResults<ItemType>>),
        pageSize: Int = 20)
    {
        self.pageSize = pageSize
        super.init(
            itemToCellViewModelBlock: itemToCellViewModelBlock,
            cellViewModelToItemBlock: cellViewModelToItemBlock,
            fetchItemObservableFactory: fetchItemObservableFactory,
            nextPageComputerBlock: {return $0.0 + 1},
            lastPageDidLoadExaminationBlock: { (results) -> Bool in
                return results.nextPath == nil
            },
            firstPageIndex: 1)
    }
    
    func reloadItemAtIndex(index: Int) {
        let page = index / pageSize + 1
        reloadItemsAtPage(page)
    }
    
    // MARK: - Fetch
    
    private func reloadItemsAtPage(page: Int) {
        fetchItemObservableFactory(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let results):
                    self?.replaceItemsAtPage(page, withResults: results)
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
    
    private func replaceItemsAtPage(page: Int, withResults results: PagedResults<ItemType>) {
        
        switch state.value {
        case .Loaded(let models, let numberOfPages, let lastResults):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .Loaded(cells: swappedModels, page: numberOfPages, lastPageResults: lastResults)
        case .LoadedAllContent(let models, let numberOfPages):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .LoadedAllContent(cells: swappedModels, page: numberOfPages)
        default:
            break
        }
    }
    
    private func swapCellViewModels(currentCellViewModels: [CellViewModelType], withProfiles profiles: [ItemType], atPage page: Int) -> [CellViewModelType] {
        
        let pageStartIndex = (page - 1) * pageSize
        let pageEndIndex = pageStartIndex + profiles.count
        let range: Range<Int> = pageStartIndex..<pageEndIndex
        let newModels = profiles.map{itemToCellViewModelBlock($0)}
        
        var models = currentCellViewModels
        models.replaceRange(range, with: newModels)
        return models
    }
}
