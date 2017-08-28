//
//  LoginFlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class LoginFlowController: FlowController {
    
    var loginFinishedBlock: ((Bool) -> Void)?
    
    init(navigationController: UINavigationController, skipIntro: Bool = false) {
        super.init(navigationController: navigationController)
        
        if skipIntro {
            self.showLoginChoice()
        } else {
            self.showIntroController()
        }
    }
    
    func showIntroController() {
        // create initial view controller
        let controller = Wireframe.introViewController()
        controller.viewModel = IntroViewModel()
        controller.flowDelegate = self
        navigationController.show(controller, sender: nil)
    }
}

extension LoginFlowController: ApplicationMainViewControllerRootObject {}

extension LoginFlowController  {
    
    func showLoginChoice() {
        
        let controller = Wireframe.loginMethodChoiceViewController()
        controller.viewModel = LoginMethodChoiceViewModel()
        controller.flowDelegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: controller, action: #selector(LoginMethodChoiceViewController.dismisss))
        navigationController.show(controller, sender: nil)
    }
}

