//
//  ShoutFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        if let snavigation = navigationController as? SHNavigationViewController {
            snavigation.ignoreToggleMenu = true
        }
        
        navigationController.navigationBarHidden = true
        
        let controller = Wireframe.shoutViewController()

        navigationController.showViewController(controller, sender: nil)
    }
    
    func requiresLoggedInUser() -> Bool {
        return true
    }
}