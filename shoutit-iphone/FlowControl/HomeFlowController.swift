//
//  HomeFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class HomeFlowController: FlowController {

    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.homeViewController()
        controller.flowDelegate = self

        navigationController.showViewController(controller, sender: nil)
    }
}