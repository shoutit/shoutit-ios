//
//  DiscoverGeneralViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class DiscoverGeneralViewModel: DiscoverViewModel {
    let disposeBag = DisposeBag()
    
    override func retriveDiscoverItems() {
        Account.sharedInstance.userSubject.asObservable().map { (user) -> String? in
            return user?.location?.country
        }.flatMap { (location) in
                return APIDiscoverService.discover(forCountry: location)
        }.map({ (items) -> DiscoverItem? in
                if (items.count > 0) {
                    return items[0]
                }
                return nil
        }).flatMap({ (item) in
            return APIDiscoverService.discoverItems(forDiscoverItem: item)
        }).subscribeNext { [weak self] (mainItem, itms) -> Void in
            
            self?.items.on(.Next((mainItem,itms)))
            
            if let mainDiscover = mainItem {
                APIShoutsService.shouts(forDiscoverItem: mainDiscover).subscribeNext({ [weak self] (shouts) -> Void in
                    self?.shouts.on(.Next(shouts))
                }).addDisposableTo((self?.disposeBag)!)
            }
            
            
        }.addDisposableTo(disposeBag)
    }
}
