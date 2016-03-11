//
//  ShoutDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ShoutDisplayable {
    func showShout(shout: Shout) -> Void
    func showShoutsForDiscoverItem(discoverItem: DiscoverItem?) -> Void
    func showDiscover() -> Void
    func showDiscoverForDiscoverItem(discoverItem: DiscoverItem?) -> Void
}

extension ShoutDisplayable where Self: FlowController, Self: ShoutDetailTableViewControllerFlowDelegate {
    
    func showShout(shout: Shout) {
        
        let controller = Wireframe.shoutDetailContainerViewController()
        controller.viewModel = ShoutDetailViewModel(shout: shout)
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
}

extension ShoutDisplayable where Self: FlowController, Self: DiscoverShoutsParentViewControllerFlowDelegate {
    func showShoutsForDiscoverItem(discoverItem: DiscoverItem?) {
        let controller = Wireframe.discoverShoutsViewController()
        
        controller.flowDelegate = self
        
        if let item = discoverItem {
            controller.viewModel = DiscoverShoutsViewModel(discoverItem: item)
        }
        
        navigationController.showViewController(controller, sender: nil)
    }

}

extension ShoutDisplayable where Self: FlowController, Self: DiscoverCollectionViewControllerFlowDelegate {
    func showDiscover() -> Void {
        let controller = Wireframe.discoverViewController()
        
        controller.flowDelegate = self
        
        controller.viewModel = DiscoverGeneralViewModel()
        
        navigationController.showViewController(controller, sender: nil)
    }
    
}

extension ShoutDisplayable where Self: FlowController, Self: DiscoverCollectionViewControllerFlowDelegate {
    
    func showDiscoverForDiscoverItem(discoverItem: DiscoverItem?) -> Void {
        let controller = Wireframe.discoverViewController()
        
        controller.flowDelegate = self
        
        if let item = discoverItem {
            controller.viewModel = DiscoverGivenItemViewModel(discoverItem: item)
        } else {
            controller.viewModel = DiscoverGeneralViewModel()
        }
        
        navigationController.showViewController(controller, sender: nil)
    }
    
}

