//
//  StaticPageFlowController.swift
//  shoutit
//
//  Created by Piotr Bernad on 08/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class StaticPageFlowController: FlowController {
    
    init(navigationController: UINavigationController, url: URL) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.staticPageViewController()
        
        controller.flowDelegate = self
        controller.urlToLoad = url
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return false
    }
}
