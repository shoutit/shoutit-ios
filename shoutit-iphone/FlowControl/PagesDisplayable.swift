//
//  PagesDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 07/09/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation


protocol PagesDisplayable {
    func showPagesList()
}

extension FlowController : PagesDisplayable {
    func showPagesList() {
        let controller = Wireframe.pagesListParentViewController()
        
        controller.flowDelegate = self
        
        navigationController.showViewController(controller, sender: nil)
    }
}