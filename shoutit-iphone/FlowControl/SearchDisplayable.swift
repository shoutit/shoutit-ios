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
    case DiscoverShouts(item: DiscoverItem)
}

protocol SearchDisplayable {
    func showSearchInContext(context: SearchContext) -> Void
    func showUserSearchResultsWithPhrase(phrase: String) -> Void
}

extension SearchDisplayable where Self: FlowController, Self: SearchViewControllerFlowDelegate {
    
    func showSearchInContext(context: SearchContext) {
        let controller = Wireframe.searchViewController()
        controller.flowDelegate = self
        controller.viewModel = SearchViewModel(context: context)
        navigationController.showViewController(controller, sender: nil)
    }
}

extension SearchDisplayable where Self: FlowController {
    
    func showUserSearchResultsWithPhrase(phrase: String) {
        let controller = Wireframe.searchUserResultsTableViewController()
        controller.viewModel = SearchUserResultsViewModel(searchPhrase: phrase)
        navigationController.showViewController(controller, sender: nil)
    }
}
