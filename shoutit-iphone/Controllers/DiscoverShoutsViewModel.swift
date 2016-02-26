//
//  DiscoverShoutsViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class DiscoverShoutsViewModel: HomeShoutsViewModel {
    
    let discoverItem : DiscoverItem
    
    init(discoverItem: DiscoverItem) {
        self.discoverItem = discoverItem
    }
    
    func headerTitle() -> String {
        return discoverItem.title
    }
    
    override func retriveShouts() -> Observable<[Shout]> {
        return APIShoutsService.shouts(forDiscoverItem: self.discoverItem, page_size: 20)
    }
    
    override func loadMorePage(page: Int) -> Observable<[Shout]> {
        print("loading page \(page)")
        return APIShoutsService.shouts(forDiscoverItem: self.discoverItem, page_size: 20, page: self.currentPage)
    }
}
