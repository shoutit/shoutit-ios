//
//  DiscoverGeneralViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class DiscoverGeneralViewModel: DiscoverViewModel {
    let disposeBag = DisposeBag()
    
    override func retriveDiscoverItems() {
        Account.sharedInstance.userSubject.asObservable().map { (user) -> String? in
            return user?.location.country
        }.flatMap { (location) in
            return APIDiscoverService.discoverItemsWithParams(FilteredDiscoverItemsParams(country: location))
        }.map{ (items) -> DiscoverItem? in
                if (items.count > 0) {
                    return items[0]
                }
                return nil
        }
        .filter { $0 != nil }
        .flatMap{ (item) in
            return APIDiscoverService.discoverItems(forDiscoverItem: item!)
        }.subscribeNext { [weak self] detailedItem -> Void in
            
            self?.items.on(.Next((detailedItem.simpleForm(), detailedItem.children)))
            
            let params = FilteredShoutsParams(discoverId: detailedItem.id, page: 1, pageSize: 4)
            APIShoutsService.listShoutsWithParams(params).subscribeNext({ [weak self] (shouts) -> Void in
                self?.shouts.on(.Next(shouts))
                }).addDisposableTo((self?.disposeBag)!)
        }.addDisposableTo(disposeBag)
    }
}
