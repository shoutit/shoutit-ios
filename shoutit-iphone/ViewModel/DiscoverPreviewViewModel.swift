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
    
    func cellReuseIdentifier() -> String {
        return reuseIdentifier
    }
    
    func headerIdentifier() -> String {
        return discoverPreviewHeaderReuseIdentifier
    }
}
