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
}

extension ShoutDisplayable where Self: FlowController, Self: ShoutDetailTableViewControllerFlowDelegate {
    
    func showShout(shout: Shout) {
        
        let controller = Wireframe.shoutDetailTableViewController()
        controller.viewModel = ShoutDetailViewModel(shout: shout)
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
}
