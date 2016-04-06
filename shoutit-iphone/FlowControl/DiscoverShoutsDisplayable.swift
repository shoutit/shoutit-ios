//
//  DiscoverShoutsDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol DiscoverShoutsDisplayable {
    func showDiscoverItem(item: DiscoverItem) -> Void
}

extension DiscoverShoutsDisplayable where Self: FlowController, Self: DiscoverCollectionViewControllerFlowDelegate {
    
    func showDiscoverItem(item: DiscoverItem) {
        
        let controller = Wireframe.discoverViewController()
        controller.flowDelegate = self
        controller.viewModel = DiscoverGivenItemViewModel(discoverItem: item)
        
        navigationController.showViewController(controller, sender: nil)
    }
}
