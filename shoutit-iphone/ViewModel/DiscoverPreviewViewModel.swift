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
    case Loading
    case NoItems
    case Loaded
}

class DiscoverPreviewViewModel: AnyObject {
    
    let displayable = ShoutsDisplayable(layout: .HorizontalGrid)
    let reuseIdentifier = "DiscoverPreviewCell"
    let discoverPreviewHeaderReuseIdentifier = "shoutDiscoverTitleCell"
    
    var state = Variable(DiscoverPreviewState.Loading)
    var dataSource : Observable<[DiscoverItem]>?
    
    func cellReuseIdentifier() -> String {
        return reuseIdentifier
    }
    
    func headerIdentifier() -> String {
        return discoverPreviewHeaderReuseIdentifier
    }
    
    required init() {
        dataSource = Account.sharedInstance.userSubject.asObservable().map { (user) -> String? in
            return user?.location.country
        }.flatMap { (location) in
            return APIDiscoverService.discover(forCountry: location)
        }.flatMap({ (items) in
            return APIDiscoverService.shouts(forDiscoverItem: items[0])
        })   
    }
}
