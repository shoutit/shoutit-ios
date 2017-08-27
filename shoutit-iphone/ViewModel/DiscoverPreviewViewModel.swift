 //
 //  DiscoverPreviewViewModel.swift
 //  shoutit-iphone
 //
 //  Created by Piotr Bernad on 15.02.2016.
 //  Copyright © 2016 Shoutit. All rights reserved.
 //
 
 import UIKit
 import RxSwift
 import RxCocoa
 import ShoutitKit
 
 enum DiscoverPreviewState {
    case notLoaded
    case loading
    case noItems
    case loaded
 }
 
 final class DiscoverPreviewViewModel {
    
    let displayable = ShoutsDisplayable(layout: ShoutsLayout.horizontalGrid)
    let reuseIdentifier = "DiscoverPreviewCell"
    let discoverPreviewHeaderReuseIdentifier = "shoutDiscoverTitleCell"
    
    var state = Variable(DiscoverPreviewState.loading)
    fileprivate(set) var dataSource : Observable<[DiscoverItem]>
    fileprivate(set) var mainItemObservable : Observable<DiscoverItem?>
    
    fileprivate let disposeBag = DisposeBag()
    
    func cellReuseIdentifier() -> String {
        return reuseIdentifier
    }
    
    func headerIdentifier() -> String {
        return discoverPreviewHeaderReuseIdentifier
    }
    
    required init() {
        
        mainItemObservable = Account.sharedInstance
            .userSubject
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs?.id == rhs?.id && lhs?.location.address == rhs?.location.address
            }
            .filter{$0 != nil}
            .flatMap { (user) in
                return APIDiscoverService.discoverItemsWithParams(FilteredDiscoverItemsParams(country: user?.location.country, location: user?.location))
            }.map{ (items) -> DiscoverItem? in
                if (items.count > 0) {
                    return items[0]
                }
                return nil
            }
            .share()
        
        dataSource = mainItemObservable
            .filter{$0 != nil}
            .flatMap{ (item) -> Observable<DetailedDiscoverItem> in
                return APIDiscoverService.discoverItems(forDiscoverItem: item!)
            }
            .flatMap{ detailedItem -> Observable<[DiscoverItem]> in
                return Observable.just(detailedItem.children)
            }
            .share()
        
        mainItemObservable
            .subscribe(onNext: {[weak self] (mainItem) -> Void in
                if let _ = mainItem {
                    self?.state.value = .loading
                } else {
                    self?.state.value = .noItems
                }
            })
            .addDisposableTo(disposeBag)
        
        dataSource
            .subscribe(onNext: {[weak self] (items) -> Void in
                self?.state.value = .loaded
            })
            .addDisposableTo(disposeBag)
        
    }
 }
