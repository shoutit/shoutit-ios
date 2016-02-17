//
//  ProfileFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ProfileFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.profileViewController()
        controller.viewModel = ProfileCollectionViewModel(user: Account.sharedInstance.user!)

        navigationController.showViewController(controller, sender: nil)
    }
    
    func requiresLoggedInUser() -> Bool {
        return true
    }
}