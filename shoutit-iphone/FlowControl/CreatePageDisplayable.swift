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
    
    func showCreatePage() {
        let controller = Wireframe.createPageViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
    
    func showCreatePageInfo(category: PageCategory) {
        let controller = Wireframe.createPageInfoViewController()
        
        controller.flowDelegate = self
        
        controller.preselectedCategory = category
        
        navigationController.showViewController(controller, sender: nil)
    }
    
}