//
//  DiscoverShoutsFlowController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class DiscoverShoutsFlowController: FlowController {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, discoverItem: DiscoverItem? = nil) {
        
        self.navigationController = navigationController
        
        // create initial view controller
        let controller = Wireframe.discoverShoutsViewController()
        
        if let item = discoverItem {
            controller.viewModel = DiscoverShoutsViewModel(discoverItem: item)
        }
        
        navigationController.showViewController(controller, sender: nil)
    }
}
