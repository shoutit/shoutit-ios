//
//  SearchDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum SearchContext {
    case General
    case ProfileShouts(profile: Profile)
    case TagShouts(tag: Tag)
    case CategoryShouts(category: Category)
    case DiscoverShouts(item: DiscoverItem)
}

protocol SearchDisplayable {
    func showSearchInContext(context: SearchContext) -> Void
    func showUserSearchResultsWithPhrase(phrase: String) -> Void
    func showShoutsSearchResultsWithPhrase(phrase: String?, context: SearchContext) -> Void
}

extension FlowController : SearchDisplayable {
    
    func showUserSearchResultsWithPhrase(phrase: String) {
        let controller = Wireframe.searchUserResultsTableViewController()
        controller.viewModel = SearchUserResultsViewModel(searchPhrase: phrase)
        controller.eventHandler = ShowProfileProfilesListEventHandler(profileDisplayable: self)
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showShoutsSearchResultsWithPhrase(phrase: String?, context: SearchContext) {
        let controller = Wireframe.searchShoutsResultsCollectionViewController()
        controller.viewModel = SearchShoutsResultsViewModel(searchPhrase: phrase, inContext: context)
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showSearchInContext(context: SearchContext) {
        let controller = Wireframe.searchViewController()
        controller.flowDelegate = self
        controller.viewModel = SearchViewModel(context: context)
        navigationController.showViewController(controller, sender: nil)
    }
}
