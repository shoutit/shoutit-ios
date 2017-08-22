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
    func showPromoteViewWithShout(_ shout: Shout) -> Void
    func showPromotedViewWithShout(_ shout: Shout) -> Void
}

extension FlowController: PromoteDisplayable {
    
    func showPromoteViewWithShout(_ shout: Shout) {
        let controller = Wireframe.promoteShoutTableViewController()
        controller.viewModel = PromoteShoutViewModel(shout: shout)
        controller.flowDelegate = self
        let modalNavigationController = ModalNavigationController(rootViewController: controller)
        navigationController.present(modalNavigationController, animated: true, completion: nil)
    }
    
    func showPromotedViewWithShout(_ shout: Shout) {
        let controller = Wireframe.promotedShoutViewController()
        controller.viewModel = PromotedShoutViewModel(shout: shout)
        controller.flowDelegate = self
        let modalNavigationController = ModalNavigationController(rootViewController: controller)
        navigationController.present(modalNavigationController, animated: true, completion: nil)
    }
}
