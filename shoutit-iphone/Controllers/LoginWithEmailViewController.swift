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

protocol LoginWithEmailViewControllerFlowDelegate: class, FeedbackDisplayable, HelpDisplayable, AboutDisplayable, TermsAndPolicyDisplayable {}

protocol LoginWithEmailViewControllerChildDelegate: class {
    func presentLogin()
    func presentSignup()
    func showErrorMessage(message: String)
}

final class LoginWithEmailViewController: UIViewController, ContainerController {
    
    // animation
    let animationDuration: Double = 0.25
    let signupViewHeight: CGFloat = 406
    let loginViewHeight: CGFloat = 326
    
    //
    private var timer: NSTimer?
    
    // UI
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    // navigation
    weak var flowDelegate: LoginWithEmailViewControllerFlowDelegate?
    
    // view model
    var viewModel: LoginWithEmailViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // child controllers
    lazy var loginViewController: LoginViewController = {
        let controller = Wireframe.loginViewController()
        controller.viewModel = LoginViewModel()
        controller.delegate = self
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    lazy var signupViewController: SignupViewController = {
        let controller = Wireframe.signupViewController()
        controller.viewModel = SignupViewModel()
        controller.delegate = self
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        
        // show initial child
        title = signupViewController.title
        containerHeightConstraint.constant = signupViewHeight
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
    
    func hideMessageLabel() {
        timer?.invalidate()
        timer = nil
        errorMessageLabel.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5) { [weak self] in
            self?.errorMessageLabel.alpha = 0.0
        }
        errorMessageLabel.hidden = true
    }
}

extension LoginWithEmailViewController: LoginWithEmailViewControllerChildDelegate {
    
    func presentLogin() {
        title = loginViewController.title
        containerHeightConstraint.constant = loginViewHeight
        cycleFromViewController(signupViewController, toViewController: loginViewController, animated: true)
    }
    
    func presentSignup() {
        title = signupViewController.title
        containerHeightConstraint.constant = signupViewHeight
        cycleFromViewController(loginViewController, toViewController: signupViewController, animated: true)
    }
    
    func showErrorMessage(message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.hidden = false
        errorMessageLabel.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5) {[weak self] in
            self?.errorMessageLabel.alpha = 1.0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "hideMessageLabel", userInfo: nil, repeats: false)
    }
}
