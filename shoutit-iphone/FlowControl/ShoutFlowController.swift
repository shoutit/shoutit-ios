//
//  ShoutFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutFlowController: FlowController {
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        // create initial view controller
        if let snavigation = navigationController as? SHNavigationViewController {
            snavigation.ignoreToggleMenu = true
        }
        
        let controller = Wireframe.shoutViewController()

        navigationController.show(controller, sender: nil)
    }
    
    override func requiresLoggedInUser() -> Bool {
        return true
    }

    override func handleDeeplink(_ deepLink: DPLDeepLink?) {
        
        guard let createShoutViewController = self.navigationController.visibleViewController as? CreateShoutPopupViewController else {
            print(self.navigationController.visibleViewController)
            return
        }
        
        guard let dplink = deepLink, let shoutType = dplink.queryParameters["shout_type"] as? String else {
            return
        }
        
        if shoutType == "offer" {
            createShoutViewController.createOffer()
        } else if shoutType == "request" {
            createShoutViewController.createRequest()
        }
    }
}
