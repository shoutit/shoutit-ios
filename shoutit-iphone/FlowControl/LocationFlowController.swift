//
//  LocationFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LocationFlowController: FlowController {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.locationViewController()
        
        navigationController.showViewController(controller, sender: nil)
    }
}
