//
//  VerifyBussinessDisplayable.swift
//  shoutit
//
//  Created by Piotr Bernad on 12/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit

protocol VerifyPageDisplayable {
    func showVerifyBussiness(page: DetailedPageProfile) -> Void
}

extension FlowController : VerifyPageDisplayable {
    
    func showVerifyBussiness(page: DetailedPageProfile) -> Void {
        let controller = Wireframe.verifyPageViewController()
    
        controller.page = page
    
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
