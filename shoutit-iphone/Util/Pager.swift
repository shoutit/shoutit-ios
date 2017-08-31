//
//  Pager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import JSONCodable
import ShoutitKit
import FBAudienceNetwork
import CocoaLumberjackSwift

enum PagerError: Error {
    case stateDoesNotAllowManipulation
    case indexExceedsBounds
}

class Pager<PageIndexType: Equatable, CellViewModelType, ItemType: JSONCodable> {
    
    fileprivate(set) var requestDisposeBag: DisposeBag = DisposeBag()
    fileprivate(set) var state: Variable<PagedViewModelState<CellViewModelType, PageIndexType, ItemType>> = Variable(.idle)
    fileprivate(set) var numberOfResults: Int?
    
    let showAds : Bool
    var loadedAds : [FBNativeAd] = []
    var adPositionCycle = 20
    var adProvider : PagerAdProvider!
    let firstPageIndex: PageIndexType
    fileprivate let disposeBag = DisposeBag()
    
    let itemToCellViewModelBlock: ((ItemType) -> CellViewModelType)
    let cellViewModelToItemBlock: ((CellViewModelType) -> ItemType)
    let fetchItemObservableFactory: ((PageIndexType) -> Observable<PagedResults<ItemType>>)
    let nextPageComputerBlock: ((PageIndexType, PagedResults<ItemType>) -> PageIndexType)
    let lastPageDidLoadExaminationBlock: ((PagedResults<ItemType>) -> Bool)
    var itemExclusionRule: ((ItemType) -> Bool)? // return true if item should be excluded
    
    init(itemToCellViewModelBlock: @escaping (ItemType) -> CellViewModelType,
         cellViewModelToItemBlock: @escaping (CellViewModelType) -> ItemType,
         fetchItemObservableFactory: @escaping ((PageIndexType) -> Observable<PagedResults<ItemType>>),
         nextPageComputerBlock: @escaping ((PageIndexType, PagedResults<ItemType>) -> PageIndexType),
         lastPageDidLoadExaminationBlock: @escaping ((PagedResults<ItemType>) -> Bool),
         firstPageIndex: PageIndexType,
         showAds : Bool = false) {
        self.itemToCellViewModelBlock = itemToCellViewModelBlock
        self.cellViewModelToItemBlock = cellViewModelToItemBlock
        self.fetchItemObservableFactory = fetchItemObservableFactory
        self.nextPageComputerBlock = nextPageComputerBlock
        self.lastPageDidLoadExaminationBlock = lastPageDidLoadExaminationBlock
        self.firstPageIndex = firstPageIndex
        self.showAds = showAds
        
        if self.showAds {
            self.createAdProvider()
            self.subscribeForChangesToInjectAds()
        }
    }
    
    func loadContent() {
        state.value = .loading
        fetchPage(firstPageIndex)
    }

    func refreshContent() {
        switch state.value {
        case let .loaded(cells, page, _):
            state.value = .refreshing(cells: cells, page: page)
            fetchPage(firstPageIndex)
        case let .loadedAllContent(cells, page):
            state.value = .refreshing(cells: cells, page: page)
            fetchPage(firstPageIndex)
        case let .loadingMore(cells, currentPage, _):
            state.value = .refreshing(cells: cells, page: currentPage)
            fetchPage(firstPageIndex)
        case .refreshing:
            break
        default:
            loadContent()
        }
    }
    
    func fetchNextPage() {
        if case .loadedAllContent = state.value { return }
        guard case .loaded(let cells, let page, let results) = state.value else { return }
        let pageToLoad = nextPageComputerBlock(page, results)
        self.state.value = .loadingMore(cells: cells, currentPage: page, loadingPage: pageToLoad)
        fetchPage(pageToLoad)
    }
    
    func replaceItemAtIndex(_ index: Int, withItem item: ItemType) throws {
        switch state.value {
        case .loaded(var cells, let page, let lastPageResults):
            guard index < cells.count else { throw PagerError.indexExceedsBounds }
            cells[index] = itemToCellViewModelBlock(item)
            state.value = .loaded(cells: cells, page: page, lastPageResults: lastPageResults)
        case .loadedAllContent(var cells, let page):
            guard index < cells.count else { throw PagerError.indexExceedsBounds }
            cells[index] = itemToCellViewModelBlock(item)
            state.value = .loadedAllContent(cells: cells, page: page)
        default:
            throw PagerError.stateDoesNotAllowManipulation
        }
    }
    
    func findItemWithComparisonBlock(_ block: ((ItemType) -> Bool)) -> (Int, ItemType)? {
        guard let (cells, _) = try? getCellViewModelsForManipulation() else { return nil }
        for (index, cell) in cells.enumerated() {
            let item = cellViewModelToItemBlock(cell)
            if block(item) {
                return (index, item)
            }
        }
        return nil
    }
    
    // MARK: - Fetch
    
    fileprivate func fetchPage(_ page: PageIndexType) {
        
        requestDisposeBag = DisposeBag()
        
        fetchItemObservableFactory(page)
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let results):
                    self?.appendItems(results, forPage: page)
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
    
    fileprivate func appendItems(_ results: PagedResults<ItemType>, forPage page: PageIndexType) {
        
        numberOfResults = results.count ?? numberOfResults
        
        let items = results.results.filter{(item) -> Bool in
            if let rule = self.itemExclusionRule {
                return !rule(item)
            }
            return true
        }
        
        if case .loadingMore(var cells, _, let loadingPage) = self.state.value, loadingPage == page {
            cells += items.map{itemToCellViewModelBlock($0)}
            if lastPageDidLoadExaminationBlock(results) {
                state.value = .loadedAllContent(cells: cells, page: page)
            } else {
                state.value = .loaded(cells: cells, page: page, lastPageResults: results)
            }
            return
        }
        
        assert(page == firstPageIndex)
        
        if items.count == 0 {
            state.value = .noContent
            return
        }
        
        let cellViewModels = items.map{itemToCellViewModelBlock($0)}
        if lastPageDidLoadExaminationBlock(results) {
            state.value = .loadedAllContent(cells: cellViewModels, page: page)
        } else {
            state.value = .loaded(cells: cellViewModels, page: page, lastPageResults: results)
        }
    }
    
    fileprivate func getCellViewModelsForManipulation() throws -> ([CellViewModelType], PageIndexType) {
        switch state.value {
        case .loaded(let cells, let page, _):
            return (cells, page)
        case .loadedAllContent(let cells, let page):
            return (cells, page)
        default:
            throw PagerError.stateDoesNotAllowManipulation
        }
    }
}

// Facebook Ads
extension Pager {
    
    func createAdProvider() {
        self.adProvider = PagerAdProvider(provide: { (ad) in
            self.loadedAds.append(ad)
            self.updateState()
        })
        
        self.adProvider.loadNextAd()
    }
    
    func subscribeForChangesToInjectAds() {
        self.state.asDriver().drive(onNext: { [weak self] state in
            
            var existingModels : [CellViewModelType] = []
            
            guard let sSelf = self else {
                return
            }
            
            if case .loaded(let models, _, _) = sSelf.state.value {
                existingModels = models
            }
            
            if case .loadedAllContent(let models, _) = sSelf.state.value {
                existingModels = models
            }
            
            if self?.shouldLoadAdsIfNeededForModels(existingModels) ?? false {
                self?.adProvider.loadNextAd()
            }
            
            }).addDisposableTo(disposeBag)
    }
    
    func shouldLoadAdsIfNeededForModels(_ models: [CellViewModelType]) -> Bool {
        return models.count / self.adPositionCycle > self.loadedAds.count
    }
    
    func updateState() {
        // Trigger state update to call collection reload
        self.state.value = self.state.value
    }
}

class PagerAdProvider : NSObject, FBNativeAdDelegate {
    var provide : ((FBNativeAd) -> Void)?
    
    init(provide : ((FBNativeAd) -> Void)?) {
        super.init()
        self.provide = provide
    }
    
    func loadNextAd() {
        let ad = FBNativeAd(placementID: Constants.FacebookAudience.collectionAdID)
        ad.delegate = self
        ad.load()
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: NSError) {
        print(error)
        DDLogError("FACEBOOK_AUDIENCE: \(error)")
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        DDLogVerbose("FACEBOOK_AUDIENCE: Ad Loaded - \(nativeAd.placementID)")
        self.provide?(nativeAd)
    }
}

// Collection View Helpers
extension Pager {
    func indexOf(_ shout: Shout) -> Int? {
        var i : Int = 0
        var idx : Int?
        
        let copy = self.shoutCellViewModels()
        
        for cell in copy {
            if cell.shout?.id == shout.id {
                idx = i
                break
            }
            i += 1
        }
        
        return idx
    }
    
    func indexInRealResultsOf(_ shout: Shout) -> Int? {
        var i : Int = 0
        var idx : Int?
        
        let copy = self.existingCellModels()
        
        for cellModel in copy {
            guard let cell = cellModel as? ShoutCellViewModel else {
                i += 1
                continue
            }
            
            if cell.shout?.id == shout.id {
                idx = i
                break
            }
            i += 1
        }
        
        return idx
        
    }
    
    func existingCellModels() -> [CellViewModelType] {
        var existingCells : [CellViewModelType] = []
        
        switch state.value {
        case let .loaded(cells, _, _):
            existingCells = cells
        case let .loadedAllContent(cells, _):
            existingCells = cells
        case let .loadingMore(cells, _, _):
            existingCells = cells
        case let .refreshing(cells, _):
            existingCells = cells
        default:
            break
        }
        
        return existingCells
    }
    
    func shoutCellViewModels() -> [ShoutCellViewModel] {
        var result : [ShoutCellViewModel] = []
        let existingCells : [CellViewModelType] = existingCellModels()
        
        existingCells.each { (cell) in
            if let shoutCell = cell as? ShoutCellViewModel {
                result.append(shoutCell)
            }
        }
        
        var adPosition: Int = 0
        
        for ad in self.loadedAds {
            let position = (adPosition + 1) * adPositionCycle
            
            if position <= result.count {
                result.insert(ShoutCellViewModel(ad: ad), at: position)
            }
            
            adPosition = adPosition + 1
        }
        
        return result
    }
}
