//
//  SearchDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum SearchContext {
    case ProfileShouts(profile: Profile)
    case TagShouts(tag: Tag)
    case DiscoverShouts(item: DiscoverItem)
}

protocol SearchDisplayable {
    func showSearchInContext(context: SearchContext) -> Void
}

extension SearchDisplayable where Self: FlowController {
    
    func showSearch() {
        navigationController.notImplemented()
    }
}
