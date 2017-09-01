//
//  AdminsFlowController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class AdminsFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.adminsListParentViewController()
        controller.viewModel = AdminsListViewModel()
        controller.flowDelegate = self
        
        navigationController.show(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
}
