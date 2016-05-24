//
//  LocationFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import GooglePlaces

final class LocationFlowController: FlowController {
    
    var finishedBlock: ((Bool, Address?) -> Void)? {
        didSet {
            if let locationController = self.navigationController.viewControllers[0] as? ChangeLocationTableViewController {
                locationController.finishedBlock = finishedBlock
            }
        }
    }
    
    init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        
        if let navigationController = navigationController as? SHNavigationViewController {
            navigationController.ignoreTabbarAppearance = true
        }
        
        // create initial view controller
        let controller = Wireframe.locationViewController()
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    func setShouldShowAutoUpdates(value: Bool) {
        if let locationController = self.navigationController.viewControllers[0] as? ChangeLocationTableViewController {
            locationController.shouldShowAutoUpdates = value
        }
    }
}
