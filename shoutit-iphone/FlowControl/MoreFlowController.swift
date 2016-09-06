//
//  MoreFlowController.swift
//  shoutit
//
//  Created by Piotr Bernad on 06/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class MoreFlowController: FlowController {
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.moreViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return false
    }
}
