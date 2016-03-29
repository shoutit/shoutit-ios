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

protocol LoginWithEmailViewControllerFlowDelegate: class, FeedbackDisplayable, HelpDisplayable, AboutDisplayable, TermsAndPolicyDisplayable, PostSignupDisplayable, LoginFinishable {}

protocol LoginWithEmailViewControllerChildDelegate: class {
    func presentLogin()
    func presentSignup()
    func presentResetPassword()
    func showErrorMessage(message: String)
}

final class LoginWithEmailViewController: UIViewController, ContainerController {
    
    // animation
    internal let animationDuration: Double = 0.25
    private let signupViewHeight: CGFloat = 416
    private let loginViewHeight: CGFloat = 326
    private let resetPasswordViewHeight: CGFloat = 188
    
    //
    private var timer: NSTimer?
    
    // UI
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    // navigation
    weak var flowDelegate: LoginWithEmailViewControllerFlowDelegate?
    
    // view model
    var viewModel: LoginWithEmailViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // child controllers
    lazy var loginViewController: LoginViewController = {
        let controller = Wireframe.loginViewController()
        controller.viewModel = self.viewModel
        controller.delegate = self
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
        addInitialViewController(signupViewController)
        
        // signup up for keyboard presentation notifications
        setupKeyboardNotifcationListenerForScrollView(scrollView)
    }
    
    deinit {
        removeKeyboardNotificationListeners()
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
        
        // view model subjects
        viewModel.errorSubject.subscribeNext {[weak self] (error) -> Void in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.sh_message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        viewModel.loginSuccessSubject.subscribeNext {[weak self] (isNewSignup) -> Void in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                if isNewSignup {
                    self?.flowDelegate?.showPostSignupInterests()
                } else {
                    self?.flowDelegate?.didFinishLoginProcessWithSuccess(true)
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject.subscribeNext{[weak self] (message) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                let alertController = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
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
        let currentChild: UIViewController = self.childViewControllers.contains(signupViewController) ? signupViewController : resetPasswordViewController
        cycleFromViewController(currentChild, toViewController: loginViewController, animated: true)
    }
    
    func presentSignup() {
        title = signupViewController.title
        containerHeightConstraint.constant = signupViewHeight
        cycleFromViewController(loginViewController, toViewController: signupViewController, animated: true)
    }
    
    func presentResetPassword() {
        title = resetPasswordViewController.title
        containerHeightConstraint.constant = resetPasswordViewHeight
        cycleFromViewController(loginViewController, toViewController: resetPasswordViewController, animated: true)
    }
    
    func showErrorMessage(message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.hidden = false
        errorMessageLabel.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5) {[weak self] in
            self?.errorMessageLabel.alpha = 1.0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(LoginWithEmailViewController.hideMessageLabel), userInfo: nil, repeats: false)
    }
}
