//
//  DiscoverGivenItemViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

final class DiscoverGivenItemViewModel: DiscoverViewModel {
    let disposeBag = DisposeBag()
    
    let itemToShow : DiscoverItem!
    
    init(discoverItem : DiscoverItem) {
        self.itemToShow = discoverItem
    }
    
    override func retriveDiscoverItems() {
        
        APIDiscoverService
            .discoverItems(forDiscoverItem: self.itemToShow)
            .subscribeNext { [weak self] detailedItem -> Void in
                self?.items.on(.Next((detailedItem.simpleForm(), detailedItem.children)))
                let params = FilteredShoutsParams(discoverId: detailedItem.id, page: 1, pageSize: 4)
                APIShoutsService.listShoutsWithParams(params)
                    .subscribeNext{ [weak self] (shouts) -> Void in
                        self?.shouts.on(.Next(shouts))
                    }
                    .addDisposableTo((self?.disposeBag)!)
            }
            .addDisposableTo(disposeBag)
        
    }
}
