//
//  OrdersFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class OrdersFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.ordersViewController()

        navigationController.show(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
}
