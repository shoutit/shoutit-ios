//
//  BookmarksFlowController.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class BookmarksFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.bookmarksViewController()
        
        
        guard let profile = Account.sharedInstance.profile else {
            return
        }
        
        let viewModel = ShoutsCollectionViewModel(context: .bookmarkedShouts(user: profile))
        
        controller.viewModel = viewModel
        controller.flowDelegate = self
        
        navigationController.show(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return false
    }
}
