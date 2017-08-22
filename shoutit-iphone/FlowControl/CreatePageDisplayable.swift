//
//  CreatePageDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol CreatePageDisplayable {
    func showCreateShout() -> Void
}

extension FlowController : CreatePageDisplayable {
    
    func showCreatePage(_ loginViewModel: LoginWithEmailViewModel) {
        let controller = Wireframe.createPageViewController()
        
        controller.flowDelegate = self
        
        controller.viewModel = loginViewModel
        
        navigationController.show(controller, sender: nil)
    }
    
    func showCreatePageInfo(_ category: PageCategory, loginViewModel: LoginWithEmailViewModel) {
        let controller = Wireframe.createPageInfoViewController()
        
        controller.flowDelegate = self
        
        controller.preselectedCategory = category
        
        controller.viewModel = loginViewModel
        
        navigationController.show(controller, sender: nil)
    }
    
    func showCreatePageInfoForLoggedUser(_ category: PageCategory) {
        let controller = Wireframe.createPageInfoViewController()
        
        controller.flowDelegate = self
        
        controller.preselectedCategory = category
        
        navigationController.show(controller, sender: nil)
    }
    
}
