//
//  LoginFlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class LoginFlowController: FlowController {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        // setup navigation controller state
        navigationController.navigationBarHidden = true
        
        // create initial view controller
        let controller = Wireframe.introViewController()
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}

extension LoginFlowController: ApplicationMainViewControllerRootObject {}

extension LoginFlowController: IntroViewControllerFlowDelegate {
    
    final func showLoginChoice() {
        
        // setup navigation controller state
        navigationController.navigationBarHidden = false
        
        // create controller
        let controller = Wireframe.loginMethodChoiceViewController()
        controller.viewModel = LoginMethod
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}

extension LoginFlowController: LoginMethodChoiceViewControllerFlowDelegate {}
