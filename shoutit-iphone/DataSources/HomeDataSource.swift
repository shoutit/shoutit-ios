//
//  HomeDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum HomeTab {
    case MyFeed
    case ShoutitPicks
    case Discover
}

class HomeDataSource : CompoundDataSource {

    var currentTab : HomeTab = .MyFeed {
        didSet {
            self.active = false
            
            switch currentTab {
            case .MyFeed:
                self.subSources = myFeedSources
            case .ShoutitPicks:
                self.subSources = shoutitPicksSources
            case .Discover:
                self.subSources = discoverSources
            }
            
            self.active = true
        }
    }
    
    let myFeedSources : [BasicDataSource] = [ShoutsCollectionViewModel(context: .HomeShouts)]
    let shoutitPicksSources : [BasicDataSource] = []
    let discoverSources : [BasicDataSource] = []
    
    
    override init() {
        super.init()
        
        self.subSources = []
    }
}