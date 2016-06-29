//
//  ProfileFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class ProfileFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        if case .Some(.Page(_)) = Account.sharedInstance.loginState {
            controller.viewModel = MyPageCollectionViewModel()
        } else {
            controller.viewModel = MyProfileCollectionViewModel()
        }

        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
}
