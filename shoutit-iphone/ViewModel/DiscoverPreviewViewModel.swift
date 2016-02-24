 //
//  DiscoverPreviewViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

enum DiscoverPreviewState {
    case NotLoaded
    case Loading
    case NoItems
    case Loaded
}

class DiscoverPreviewViewModel: AnyObject {
    
    let displayable = ShoutsDisplayable(layout: .HorizontalGrid)
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
        
        mainItemObservable = Account.sharedInstance.userSubject.asObservable().map { (user) -> String? in
            return user?.location.country
        }.flatMap { (location) in
            return APIDiscoverService.discover(forCountry: location)
        }.map({ (items) -> DiscoverItem? in
            if (items.count > 0) {
                return items[0]
            }
            return nil
        }).share()
        
        dataSource = mainItemObservable.flatMap({ (item) -> Observable<DiscoverResult> in
            return APIDiscoverService.discoverItems(forDiscoverItem: item)
        }).flatMap({ (mainItem, items) -> Observable<[DiscoverItem]> in
            return Observable.just(items ?? [])
        }).share()
        
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
