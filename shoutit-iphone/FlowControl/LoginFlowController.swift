//
//  LoginFlowController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class LoginFlowController: FlowController {
    
    let navigationController: UINavigationController
    var loginFinishedBlock: ((Bool) -> Void)?
    
    init(navigationController: UINavigationController, skipIntro: Bool = false) {
        
        self.navigationController = navigationController
        
        if skipIntro {
            showLoginChoice()
        } else {
            showIntroController()
        }
    }
    
    func showIntroController() {
        // create initial view controller
        let controller = Wireframe.introViewController()
        controller.viewModel = IntroViewModel()
        controller.flowDelegate = self
        navigationController.showViewController(controller, sender: nil)
    }
}

extension LoginFlowController: ApplicationMainViewControllerRootObject {}

extension LoginFlowController: IntroViewControllerFlowDelegate {
    
    func showLoginChoice() {
        
        let controller = Wireframe.loginMethodChoiceViewController()
        controller.viewModel = LoginMethodChoiceViewModel()
        controller.flowDelegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: controller, action: #selector(LoginMethodChoiceViewController.dismiss))
        navigationController.showViewController(controller, sender: nil)
    }
}

extension LoginFlowController: LoginFinishable {
    
    func didFinishLoginProcessWithSuccess(success: Bool) {
        if let loginFinishedBlock = loginFinishedBlock {
            loginFinishedBlock(success)
        } else {
            navigationController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension LoginFlowController: TermsAndPolicyDisplayable {}
extension LoginFlowController: LoginMethodChoiceViewControllerFlowDelegate {}
extension LoginFlowController: LoginWithEmailViewControllerFlowDelegate {}
extension LoginFlowController: PostSignupInterestsViewControllerFlowDelegate {}
extension LoginFlowController: PostSignupSuggestionViewControllerFlowDelegate {}

