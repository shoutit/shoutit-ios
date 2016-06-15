//
//  DiscoverShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class DiscoverShoutsViewModel: HomeShoutsViewModel {
    
    let discoverItem : DiscoverItem
    
    init(discoverItem: DiscoverItem) {
        self.discoverItem = discoverItem
    }
    
    func headerTitle() -> String {
        return discoverItem.title
    }
    
    override func retriveShouts() -> Observable<[Shout]> {
        let params = FilteredShoutsParams(discoverId: self.discoverItem.id, page: 1, pageSize: 20, currentUserLocation: Account.sharedInstance.user?.location)
        return APIShoutsService.listShoutsWithParams(params)
    }
    
    override func loadMorePage(page: Int) -> Observable<[Shout]> {
        let params = FilteredShoutsParams(discoverId: self.discoverItem.id, page: page, pageSize: 20, currentUserLocation: Account.sharedInstance.user?.location)
        return APIShoutsService.listShoutsWithParams(params)
    }
}
