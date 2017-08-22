//
//  SearchDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

enum SearchContext {
    case general
    case profileShouts(profile: Profile)
    case tagShouts(tag: Tag)
    case categoryShouts(category: ShoutitKit.Category)
    case discoverShouts(item: DiscoverItem)
}

protocol SearchDisplayable {
    func showSearchInContext(_ context: SearchContext) -> Void
    func showUserSearchResultsWithPhrase(_ phrase: String) -> Void
    func showShoutsSearchResultsWithPhrase(_ phrase: String?, context: SearchContext) -> Void
}

extension FlowController : SearchDisplayable {
    
    func showUserSearchResultsWithPhrase(_ phrase: String) {
        let controller = Wireframe.searchUserResultsTableViewController()
        controller.viewModel = SearchUserResultsViewModel(searchPhrase: phrase)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.show(controller, sender: nil)
    }
    
    func showShoutsSearchResultsWithPhrase(_ phrase: String?, context: SearchContext) {
        let controller = Wireframe.searchShoutsResultsCollectionViewController()
        controller.viewModel = SearchShoutsResultsViewModel(searchPhrase: phrase, inContext: context)
        controller.flowDelegate = self
        navigationController.show(controller, sender: nil)
    }
    
    func showSearchInContext(_ context: SearchContext) {
        let controller = Wireframe.searchViewController()
        controller.flowDelegate = self
        controller.viewModel = SearchViewModel(context: context)
        navigationController.show(controller, sender: nil)
    }
}
