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
        let controlller = Wireframe.promoteShoutTableViewController()
        controlller.viewModel = PromoteShoutViewModel(shout: shout)
        controlller.flowDelegate = self
        navigationController.showViewController(controlller, sender: nil)
    }
    
    func showPromotedViewWithShout(shout: Shout) {
        let controller = Wireframe.promotedShoutTableViewController()
        controller.viewModel = PromotedShoutViewModel(shout: shout)
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}
