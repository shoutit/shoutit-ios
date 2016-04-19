//
//  InviteFriendsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class InviteFriendsFlowController: FlowController {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.inviteFriendsViewController()
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    func requiresLoggedInUser() -> Bool {
        return true
    }
}
