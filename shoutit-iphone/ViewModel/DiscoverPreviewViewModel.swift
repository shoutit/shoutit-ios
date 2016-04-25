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
 
 enum DiscoverPreviewState {
    case NotLoaded
    case Loading
    case NoItems
    case Loaded
 }
 
 final class DiscoverPreviewViewModel: AnyObject {
    
    let displayable = ShoutsDisplayable(layout: ShoutsLayout.HorizontalGrid)
    let reuseIdentifier = "DiscoverPreviewCell"
    let discoverPreviewHeaderReuseIdentifier = "shoutDiscoverTitleCell"
    
    var state = Variable(DiscoverPreviewState.Loading)
    var dataSource : Observable<[DiscoverItem]>
    var mainItemObservable : Observable<DiscoverItem?>
    
    private let disposeBag = DisposeBag()
    
    func cellReuseIdentifier() -> String {
        return reuseIdentifier
    }
    
    func headerIdentifier() -> String {
        return discoverPreviewHeaderReuseIdentifier
    }
    
    required init() {
        
        let countryObservable : Driver<String?> = Account.sharedInstance.userSubject.asDriver(onErrorJustReturn: (nil, nil)).map { (_, let user) -> String? in
            return user?.location.country
        }
        
        
        mainItemObservable = countryObservable
            .distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
            .asObservable()
            .flatMap { (location) in
                return APIDiscoverService.discoverItemsWithParams(FilteredDiscoverItemsParams(country: location))
            }.map{ (items) -> DiscoverItem? in
                if (items.count > 0) {
                    return items[0]
                }
                return nil
            }.share()
        
        dataSource = mainItemObservable
            .filter{$0 != nil}
            .flatMap{ (item) -> Observable<DetailedDiscoverItem> in
                return APIDiscoverService.discoverItems(forDiscoverItem: item!)
            }
            .flatMap{ detailedItem -> Observable<[DiscoverItem]> in
                return Observable.just(detailedItem.children)
            }
            .share()
        
        mainItemObservable.subscribeNext { (mainItem) -> Void in
            if let _ = mainItem {
                self.state.value = .Loading
            } else {
                self.state.value = .NoItems
            }
            }.addDisposableTo(disposeBag)
        
        dataSource.subscribeNext { (items) -> Void in
            self.state.value = .Loaded
            }.addDisposableTo(disposeBag)
        
    }
 }
