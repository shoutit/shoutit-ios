//
//  DiscoverFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class DiscoverFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, discoverItem: DiscoverItem? = nil) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.discoverViewController()
        
        if let item = discoverItem {
            controller.viewModel = DiscoverGivenItemViewModel(discoverItem: item)
        }

        navigationController.showViewController(controller, sender: nil)
    }
}
