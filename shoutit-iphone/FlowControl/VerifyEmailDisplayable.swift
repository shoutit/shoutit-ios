//
//  VerifyEmailDisplayable.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol VerifyEmailDisplayable {
    func showVerifyEmailView(profile: DetailedProfile, successBlock: VerifyEmailViewController.VerifyEmailSuccessBlock) -> Void
}

extension FlowController : VerifyEmailDisplayable {
    
    func showVerifyEmailView(profile: DetailedProfile, successBlock: VerifyEmailViewController.VerifyEmailSuccessBlock) {
        let controller = Wireframe.verifyEmailViewController()
        controller.viewModel = VerifyEmailViewModel(profile: profile)
        controller.successBlock = successBlock
        let nav = ModalNavigationController(rootViewController: controller)
        navigationController.presentViewController(nav, animated: true, completion: nil)
    }
}
