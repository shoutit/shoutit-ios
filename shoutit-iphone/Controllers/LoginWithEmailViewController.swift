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
import MBProgressHUD

protocol LoginWithEmailViewControllerChildDelegate: class {
    func presentLogin()
    func presentCreatePage()
    func presentSignup()
    func presentResetPassword()
    func showLoginErrorMessage(_ message: String)
}

final class LoginWithEmailViewController: UIViewController, ContainerController {
    
    // animation
    internal let animationDuration: Double = 0.25
    fileprivate let signupViewHeight: CGFloat = 466
    fileprivate let loginViewHeight: CGFloat = 326
    fileprivate let createPageViewHeight: CGFloat = 525
    fileprivate let resetPasswordViewHeight: CGFloat = 188
    
    // UI
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var currentChildViewController: UIViewController?
    var currentControllerConstraints: [NSLayoutConstraint] = []
    
    // navigation
    weak var flowDelegate: LoginFlowController?
    
    // view model
    var viewModel: LoginWithEmailViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // child controllers
    lazy var loginViewController: LoginViewController = {
        let controller = Wireframe.loginViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    lazy var createPageViewController: CreatePageViewController = {
        let controller = Wireframe.createPageViewController()
        controller.delegate = self
        controller.viewModel = self.viewModel
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    lazy var signupViewController: SignupViewController = {
        let controller = Wireframe.signupViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
        controller.flowDelegate = self.flowDelegate
        return controller
    }()
    lazy var resetPasswordViewController: ResetPasswordViewController = {
        let controller = Wireframe.resetPasswordViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        
        // show initial child
        title = signupViewController.title
        containerHeightConstraint.constant = signupViewHeight
        changeContentTo(signupViewController)
        
        // signup up for keyboard presentation notifications
        setupKeyboardNotifcationListenerForScrollView(scrollView)
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        feedbackButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.flowDelegate?.showFeedbackInterface()
            })
            .addDisposableTo(disposeBag)
        
        helpButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.flowDelegate?.showHelpInterface()
            })
            .addDisposableTo(disposeBag)
        
        aboutButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.flowDelegate?.showAboutInterface()
            })
            .addDisposableTo(disposeBag)
        
        // view model subjects
        viewModel.errorSubject.subscribe(onNext: {[weak self] (error) -> Void in
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                self?.showError(error)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.loginSuccessSubject.subscribe(onNext: {[weak self] (isNewSignup) -> Void in
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                if isNewSignup {
                    self?.flowDelegate?.showPostSignupInterests()
                } else {
                    self?.flowDelegate?.didFinishLoginProcessWithSuccess(true)
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject.subscribe(onNext: { [weak self] (message) in
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                self?.showSuccessMessage(message)
            })
            .addDisposableTo(disposeBag)
    }
}

extension LoginWithEmailViewController: LoginWithEmailViewControllerChildDelegate {
    
    func presentLogin() {
        title = loginViewController.title
        containerHeightConstraint.constant = loginViewHeight
        changeContentTo(loginViewController, animated: true)
    }
    
    func presentCreatePage() {
        title = createPageViewController.title
        containerHeightConstraint.constant = createPageViewHeight
        changeContentTo(createPageViewController, animated: true)
    }
    
    func presentSignup() {
        title = signupViewController.title
        containerHeightConstraint.constant = signupViewHeight
        changeContentTo(signupViewController, animated: true)
    }
    
    func presentResetPassword() {
        title = resetPasswordViewController.title
        containerHeightConstraint.constant = resetPasswordViewHeight
        changeContentTo(resetPasswordViewController, animated: true)
    }
    
    func showLoginErrorMessage(_ message: String) {
        showErrorMessage(message)
    }
}
