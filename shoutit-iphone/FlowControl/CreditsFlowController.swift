//
//  CreditsFlowController.swift
//  shoutit
//
//  Created by Piotr Bernad on 10/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class CreditsFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.creditsViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
}
