//
//  LoginWithEmailViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol LoginWithEmailViewControllerFlowDelegate: class, FeedbackDisplayable, HelpDisplayable, AboutDisplayable {}

protocol LoginWithEmailViewControllerChildDelegate: class {
    func presentLogin()
    func presentSignup()
}

final class LoginWithEmailViewController: UIViewController, ContainerController {
    
    // animation
    let animationDuration: Double = 0.25
    
    // UI
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // navigation
    weak var flowDelegate: LoginWithEmailViewControllerFlowDelegate?
    
    // view model
    var viewModel: LoginWithEmailViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // child controllers
    lazy var loginViewController: LoginViewController = {
        let controller = Wireframe.loginViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
        return controller
    }()
    lazy var signupViewController: SignupViewController = {
        let controller = Wireframe.signupViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        setupRX()
        
        // show initial child
        
        addInitialViewController(signupViewController)
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        feedbackButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.showFeedbackInterface()
            }
            .addDisposableTo(disposeBag)
        
        helpButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.showHelpInterface()
            }
            .addDisposableTo(disposeBag)
        
        aboutButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.showAboutInterface()
            }
            .addDisposableTo(disposeBag)
    }
}

extension LoginWithEmailViewController: LoginWithEmailViewControllerChildDelegate {
    
    func presentLogin() {
        cycleFromViewController(signupViewController, toViewController: loginViewController, animated: true)
    }
    
    func presentSignup() {
        cycleFromViewController(loginViewController, toViewController: signupViewController, animated: true)
    }
}
