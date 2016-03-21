//
//  HomeShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class HomeShoutsViewModel: AnyObject {
    var displayable = ShoutsDisplayable(layout: .VerticalGrid)
    let listReuseIdentifier = "shShoutItemListCell"
    let gridReuseIdentifier = "shShoutItemGridCell"
    
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
            return gridReuseIdentifier
        }
        
        return listReuseIdentifier
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
        let user = Account.sharedInstance.user
        if let user = user where user.isGuest == false {
            return APIUsersService.homeShouts()
        } else {
            let countryCode = user?.location.country ?? NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
            let params = FilteredShoutsParams(page: 1, pageSize: 20, country: countryCode)
            return APIShoutsService.listShoutsWithParams(params)
        }
    }
    
    func loadMorePage(page: Int) -> Observable<[Shout]> {
        let user = Account.sharedInstance.user
        
        if let user = user where user.isGuest == false {
            return APIUsersService.homeShouts(20, page: page)
        } else {
            let countryCode = user?.location.country ?? NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
            let params = FilteredShoutsParams(page: page, pageSize: 20, country: countryCode)
            return APIShoutsService.listShoutsWithParams(params)
        }
        
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
    
}
