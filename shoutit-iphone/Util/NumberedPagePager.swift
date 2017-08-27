//
//  NumberedPagePager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit
import Alamofire
import JSONCodable

class NumberedPagePager<CellViewModelType, ItemType: JSONCodable>: Pager<Int, CellViewModelType, ItemType> {
    
    let pageSize: Int
    
    var cellViewModelsComparisonBlock: ((_ lhs: CellViewModelType, _ rhs: CellViewModelType) -> Bool)?
    init(
        itemToCellViewModelBlock: (ItemType) -> CellViewModelType,
        cellViewModelToItemBlock: (CellViewModelType) -> ItemType,
        fetchItemObservableFactory: ((Int) -> Observable<PagedResults<ItemType>>),
        pageSize: Int = 20,
        showAds: Bool = false)
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
            firstPageIndex: 1,
            showAds: showAds)
    }
    
    func reloadItemAtIndex(_ index: Int) {
        let page = index / pageSize + 1
        reloadItemsAtPage(page)
    }
    
    // MARK: - Fetch
    
    fileprivate func reloadItemsAtPage(_ page: Int) {
        fetchItemObservableFactory(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let results):
                    self?.replaceItemsAtPage(page, withResults: results)
                case .error(let error):
                    assert(false, error.sh_message)
                    self?.state.value = .error(error)
                default:
                    break
                }
            }
            .addDisposableTo(requestDisposeBag)
    }
    
    // MARK: - Helpers
    
    func replaceCellViewModels(atIndex idx: Int, withItem item: ItemType) {
        let newViewModel = itemToCellViewModelBlock(item)
        
        switch state.value {
        case .loaded(let models, let numberOfPages, let lastResults):
            var newModels : [CellViewModelType] = models
            
            newModels.remove(at: idx)
            newModels.insert(newViewModel, at: idx)
            
            state.value = .loaded(cells: newModels, page: numberOfPages, lastPageResults: lastResults)
        case .loadedAllContent(let models, let numberOfPages):
            var newModels : [CellViewModelType] = models
            
            newModels.remove(at: idx)
            newModels.insert(newViewModel, at: idx)
            
            state.value = .loadedAllContent(cells: newModels, page: numberOfPages)
        default: break
        }
        
    }
    
    fileprivate func replaceItemsAtPage(_ page: Int, withResults results: PagedResults<ItemType>) {
        
        switch state.value {
        case .loaded(let models, let numberOfPages, let lastResults):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .loaded(cells: swappedModels, page: numberOfPages, lastPageResults: lastResults)
        case .loadedAllContent(let models, let numberOfPages):
            guard numberOfPages >= page else { return }
            let swappedModels = swapCellViewModels(models, withProfiles: results.results, atPage: page)
            state.value = .loadedAllContent(cells: swappedModels, page: numberOfPages)
        default:
            break
        }
    }
    
    fileprivate func swapCellViewModels(_ currentCellViewModels: [CellViewModelType], withProfiles profiles: [ItemType], atPage page: Int) -> [CellViewModelType] {
        
        let pageStartIndex = (page - 1) * pageSize
        let pageEndIndex = pageStartIndex + profiles.count
        let range: CountableRange<Int> = pageStartIndex..<pageEndIndex
        let newModels = profiles.map{itemToCellViewModelBlock($0)}
        
        var models = currentCellViewModels
        models.replaceSubrange(range, with: newModels)
        return models
    }
}
