//
//  PromoteDisplayable.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol PromoteDisplayable {
    func showPromoteViewWithShout(shout: Shout) -> Void
    func showPromotedViewWithShout(shout: Shout) -> Void
}

extension FlowController: PromoteDisplayable {
    
    func showPromoteViewWithShout(shout: Shout) {
        let controller = Wireframe.promoteShoutTableViewController()
        controller.viewModel = PromoteShoutViewModel(shout: shout)
        controller.flowDelegate = self
        let modalNavigationController = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(modalNavigationController, animated: true, completion: nil)
    }
    
    func showPromotedViewWithShout(shout: Shout) {
        let controller = Wireframe.promotedShoutViewController()
        controller.viewModel = PromotedShoutViewModel(shout: shout)
        controller.flowDelegate = self
        let modalNavigationController = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(modalNavigationController, animated: true, completion: nil)
    }
}
