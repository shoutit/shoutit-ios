//
//  TagDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol TagDisplayable {
    func showTag(_ tag: Tag) -> Void
    func showTag(_ filter: Filter) -> Void
    func showTag(_ category: ShoutitKit.Category) -> Void
}

extension FlowController : TagDisplayable {
    
    func showTag(_ tag: Tag) {
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = TagProfileCollectionViewModel(tag: tag)
        navigationController.show(controller, sender: nil)
    }
    
    func showTag(_ filter: Filter) {
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = TagProfileCollectionViewModel(filter: filter)
        navigationController.show(controller, sender: nil)
    }
    
    func showTag(_ category: ShoutitKit.Category) {
        let controller = Wireframe.profileViewController()
        controller.flowDelegate = self
        controller.viewModel = TagProfileCollectionViewModel(category: category)
        navigationController.show(controller, sender: nil)
    }
    
    
}
