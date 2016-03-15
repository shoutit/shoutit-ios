//
//  TagDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol TagDisplayable {
    func showTag(tag: Tag) -> Void
    func showTag(filter: Filter) -> Void
}

extension EditProfileDisplayable where Self: FlowController, Self: ProfileCollectionViewControllerFlowDelegate {
    
    func showTag(tag: Tag) {
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = TagProfileCollectionViewModel(tag: tag)
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showTag(filter: Filter) {
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = TagProfileCollectionViewModel(filter: filter)
        navigationController.showViewController(controller, sender: nil)
    }
}