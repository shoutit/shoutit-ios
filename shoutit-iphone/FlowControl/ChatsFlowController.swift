//
//  ChatsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ChatsFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        let controller = Wireframe.chatsViewController()
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    override func handleDeeplink(deepLink: DPLDeepLink?) {
        guard let deepLink = deepLink else {
            return
        }
        
        if let parentController = self.navigationController.visibleViewController as? DeepLinkHandling {
            parentController.handleDeeplink(deepLink)
        }
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }
}
