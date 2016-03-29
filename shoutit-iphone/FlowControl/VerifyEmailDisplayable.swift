//
//  VerifyEmailDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol VerifyEmailDisplayable {
    func showVerifyEmailView() -> Void
}

extension VerifyEmailDisplayable where Self: FlowController {
    
    func showVerifyEmailView() {
        let controller = Wireframe.verifyEmailViewController()
        controller.viewModel = VerifyEmailViewModel()
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
