//
//  SearchFlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class SearchFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, context: SearchContext) {
        self.navigationController = navigationController
        
        let controller = Wireframe.searchViewController()
        controller.viewModel = SearchViewModel(context: context)
        
        controller.showViewController(controller, sender: nil)
    }
}