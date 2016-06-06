//
//  InviteFriendsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class InviteFriendsFlowController: FlowController {    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.inviteFriendsViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return false
    }
}
