//
//  ShoutDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol ShoutDisplayable {
    func showShout(shout: Shout) -> Void
    func showEditShout(shout: Shout) -> Void
    func showDiscover() -> Void
    func showDiscoverForDiscoverItem(discoverItem: DiscoverItem?) -> Void
}

extension FlowController : ShoutDisplayable {
    
    func showShout(shout: Shout) {
        
        if shout.id == ""{
            navigationController.showErrorMessage(NSLocalizedString("This shout has been deleted", comment: "Deleted Shout"))
        }
        else {
        let controller = Wireframe.shoutDetailContainerViewController()
        controller.viewModel = ShoutDetailViewModel(shout: shout)
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
        }
        
    }
    
    func showEditShout(shout: Shout) -> Void {
        
        let editController = Wireframe.editShoutController()
        
        editController.shout = shout
        editController.dismissAfter = true
        let navigation = SHNavigationViewController(rootViewController: editController)
        
        navigationController.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func showDiscover() -> Void {
        let controller = Wireframe.discoverViewController()
        
        controller.flowDelegate = self
        
        controller.viewModel = DiscoverGeneralViewModel()
        
        navigationController.showViewController(controller, sender: nil)
    }
    
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
