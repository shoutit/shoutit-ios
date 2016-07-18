//
//  HomeShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

enum ShoutCellsIdentifiers : String {
    case ListReuseIdentifier = "shShoutItemListCell"
    case GridReuseIdentifier = "shShoutItemGridCell"
    case AdListReuseIdentifier = "adItemListCell"
    case AdGridReuseIdentifier = "adItemGridCell"
}

class HomeShoutsViewModel: AnyObject {
    private var filtersState: FiltersState?
    var displayable = ShoutsDisplayable(layout: .VerticalGrid)
    
    let homeHeaderReuseIdentifier = "shoutMyFeedHeaderCell"
    
    let disposeBag = DisposeBag()
    let dataSubject : PublishSubject<[Shout]> = PublishSubject()
    var loadNextPage : PublishSubject<Bool>? = PublishSubject()
    var loadedPages : [Int] = [1]
    var loadingPages : [Int] = []
    
    var loading : Variable<Bool> = Variable(false)
    private var finishedLoading = false
    
    var currentPage : Int = 1
    
    init() {
        self.displayable.loadNextPage = self.loadNextPage
        
        self.loadNextPage?.subscribeNext({ [weak self] (shouldLoad) -> Void in
            self?.tryToLoadNextPage()
        }).addDisposableTo(disposeBag)
    }
    
    func cellReuseIdentifier() -> String {
        if displayable.shoutsLayout == ShoutsLayout.VerticalGrid {
            return ShoutCellsIdentifiers.GridReuseIdentifier.rawValue
        }
        
        return ShoutCellsIdentifiers.ListReuseIdentifier.rawValue
    }
    
    func adCellReuseIdentifier() -> String {
        if displayable.shoutsLayout == ShoutsLayout.VerticalGrid {
            return ShoutCellsIdentifiers.AdGridReuseIdentifier.rawValue
        }
        
        return ShoutCellsIdentifiers.AdListReuseIdentifier.rawValue
    }
    
    func changeDisplayModel() -> ShoutsLayout {
        if displayable.shoutsLayout == ShoutsLayout.VerticalGrid {
            displayable = ShoutsDisplayable(layout: .VerticalList, offset: displayable.contentOffset.value, pageSubject: self.loadNextPage)
        } else {
            displayable = ShoutsDisplayable(layout: .VerticalGrid, offset: displayable.contentOffset.value, pageSubject: self.loadNextPage)
        }
        
        return displayable.shoutsLayout
    }
    
    func retriveShouts() -> Observable<[Shout]> {
        return loadPageObservable(1)
    }
    
    func loadMorePage(page: Int) -> Observable<[Shout]> {
        return loadPageObservable(page)
    }
    
    func getFiltersState() -> FiltersState {
        return filtersState ?? FiltersState(location: (Account.sharedInstance.user?.location, .Enabled), withinDistance: (.Distance(kilometers: 20), .Enabled))
    }
    
    func applyFiltersState(state: FiltersState) {
        self.filtersState = state
    }
    
    private func tryToLoadNextPage() {
        if loadingPages.count > 0 {
            return
        }
        
        let pageToLoad = (self.loadedPages.last ?? 1) + 1
        
        if self.loadingPages.contains(pageToLoad) {
            return
        }
        
        loadPage(pageToLoad)
    }
    
    private func loadPage(page: Int) {
        if finishedLoading {
            self.loading.value = false
            return
        }
        
        self.loadingPages.append(page)
        
        self.loading.value = true
        
        self.loadMorePage(page)
            .subscribe(onNext: { [weak self] (newItems) -> Void in
                
                if newItems.count == 0 {
                    self?.finishedLoading = true
                }
                
                self?.loading.value = false
                
                self?.loadedPages.append(page)
                
                if let index = self?.loadingPages.indexOf(page) {
                    self?.loadingPages.removeAtIndex(index)
                }
                
                self?.currentPage = page
                
                self?.dataSubject.onNext(newItems)
                
                }, onError: { [weak self] (error) -> Void in
                    self?.finishedLoading = true
                }, onCompleted: {(completed) -> Void in
                }, onDisposed: { () -> Void in
                    
            }).addDisposableTo(disposeBag)
    }
    
    private func loadPageObservable(page: Int) -> Observable<[Shout]> {
        let user = Account.sharedInstance.user
        if let user = user where user.isGuest == false {
            var params = FilteredShoutsParams(page: page, pageSize: 20, currentUserLocation: Account.sharedInstance.user?.location)
            if let filtersState = filtersState {
                let filterParams = filtersState.composeParams()
                params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
            }
            return APIProfileService.homeShoutsWithParams(params)
        } else {
            var params = FilteredShoutsParams(page: page, pageSize: 20, useLocaleBasedCountryCodeWhenNil: true, skipLocation: true)
            if let filtersState = filtersState {
                let filterParams = filtersState.composeParams()
                params = filterParams.paramsByReplacingEmptyFieldsWithFieldsFrom(params)
            }
            return APIShoutsService.listShoutsWithParams(params)
        }
    }
}
