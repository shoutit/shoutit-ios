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
    func showVerifyBussiness(_ page: DetailedPageProfile) -> Void
}

extension FlowController : VerifyPageDisplayable {
    
    func showVerifyBussiness(_ page: DetailedPageProfile) -> Void {
        let controller = Wireframe.verifyPageViewController()
        
        let viewModel = VerifyPageViewModel(page: page)
        controller.viewModel = viewModel
    
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.present(nav, animated: true, completion: nil)
    }
}
