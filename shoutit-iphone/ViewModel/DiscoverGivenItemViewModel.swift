//
//  DiscoverGivenItemViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class DiscoverGivenItemViewModel: DiscoverViewModel {
    let disposeBag = DisposeBag()
    
    let itemToShow : DiscoverItem!
    
    init(discoverItem : DiscoverItem) {
        self.itemToShow = discoverItem
    }
    
    override func retriveDiscoverItems() {
        
        APIDiscoverService
            .discoverItems(forDiscoverItem: self.itemToShow)
            .subscribe(onNext: { [weak self] detailedItem -> Void in
                self?.items.on(.next((detailedItem.simpleForm(), detailedItem.children)))
                let params = FilteredShoutsParams(discoverId: detailedItem.id, page: 1, pageSize: 4, skipLocation: true)
                APIShoutsService.listShoutsWithParams(params)
                    .flatMap({ (result) -> Observable<[Shout]> in
                        return Observable.just(result.results)
                    })
                    .subscribe(onNext: { [weak self] (shouts) -> Void in
                        self?.shouts.on(.next(shouts))
                        self?.adManager.handleNewShouts(shouts)
                    })
                    .addDisposableTo((self?.disposeBag)!)
            })
            .addDisposableTo(disposeBag)
        
    }
}
