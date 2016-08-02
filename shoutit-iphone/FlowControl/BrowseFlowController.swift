//
//  BrowseFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class BrowseFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        self.navigationController = navigationController
        let controller = Wireframe.searchShoutsResultsCollectionViewController()
        controller.title = NSLocalizedString("Browse", comment: "Browse Screen Title")
        controller.viewModel = SearchShoutsResultsViewModel(searchPhrase: nil, inContext: .General)
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}
