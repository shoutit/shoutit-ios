//
//  DiscoverGeneralViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class DiscoverGeneralViewModel: DiscoverViewModel {
    let disposeBag = DisposeBag()
    
    override var isRootDiscoverView: Bool {
        return true
    }
    
    override func retriveDiscoverItems() {    
        let countryObservable : Observable<String?> = Account.sharedInstance
            .userSubject
            .flatMap({ (user) -> Observable<String?> in
                return Observable.just(user?.location.country)
            }).distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs == rhs
        }
        
        countryObservable
            .flatMap { (location) in
                return APIDiscoverService.discoverItemsWithParams(FilteredDiscoverItemsParams(country: location, location: Account.sharedInstance.user?.location))
            }
            .map{ (items) -> DiscoverItem? in
                if (items.count > 0) {
                    return items[0]
                }
                return nil
            }
            .filter { $0 != nil }
            .flatMap{ (item) in
                return APIDiscoverService.discoverItems(forDiscoverItem: item!)
            }
            .subscribeNext { [weak self] detailedItem -> Void in
                
                guard let `self` = self else { return }
                self.items.on(.Next((detailedItem.simpleForm(), detailedItem.children)))
                let params = FilteredShoutsParams(discoverId: detailedItem.id, page: 1, pageSize: 4, skipLocation: true)
                
                APIShoutsService
                    .listShoutsWithParams(params)
                    .flatMap({ (result) -> Observable<[Shout]> in
                        return Observable.just(result.results)
                    })
                    .subscribeNext{[weak self] (shouts) -> Void in
                        self?.shouts.on(.Next(shouts))
                        self?.adManager.handleNewShouts(shouts)
                    }
                    .addDisposableTo(self.disposeBag)
            }
            .addDisposableTo(disposeBag)
    }
}
