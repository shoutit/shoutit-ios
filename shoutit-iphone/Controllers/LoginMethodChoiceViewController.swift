//
//  LoginMethodChoiceViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD


final class LoginMethodChoiceViewController: UIViewController {
    
    // ui outlets
    @IBOutlet weak var loginWithFacebookButton: CustomUIButton!
    @IBOutlet weak var loginWithGoogleButton: CustomUIButton!
    @IBOutlet weak var loginWithEmailButton: CustomUIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    // view model
    var viewModel: LoginMethodChoiceViewModel!
    
    // navigation
    weak var flowDelegate: LoginFlowController?
    
    // rx
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title view
        navigationItem.titleView = UIImageView(image: UIImage.navBarLogoWhite())
        
        // configure google client
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // setup
        setupRX()
    }
    
    public func dismisss() {
        if let navigationController = self.navigationController, navigationController.viewControllers[0] !== self {
            pop()
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        // user actions observers
        loginWithFacebookButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.viewModel.loginWithFacebookFromViewController(self)
            })
            .addDisposableTo(disposeBag)
        
        loginWithGoogleButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.viewModel.loginWithGoogle()
            })
            .addDisposableTo(disposeBag)
        
        loginWithEmailButton
            .rx.tap
            .subscribe(onNext: { [unowned self] in
                self.flowDelegate?.showLoginWithEmail()
            })
            .addDisposableTo(disposeBag)
        
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
        
        // view model observers
        
        viewModel.errorSubject.subscribe(onNext: {[weak self] (error) -> Void in
            self?.showError(error)
        }).addDisposableTo(disposeBag)
        
        viewModel.loginSuccessSubject.subscribe(onNext: {[weak self] (isNewSignup) -> Void in
            if isNewSignup {
                self?.flowDelegate?.showPostSignupInterests()
            } else {
                self?.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
        }).addDisposableTo(disposeBag)
        
        viewModel.progressHUDSubject.subscribe(onNext: { [weak self](show) in
            if show {
                if let view = self?.view {
                            MBProgressHUD.showAdded(to: view, animated: true)
                        }
            } else {
                if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
            }
        }).addDisposableTo(disposeBag)
    }
}

extension LoginMethodChoiceViewController: GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        if let viewController = viewController as? UINavigationController {
            viewController.navigationBar.tintColor = UIColor(shoutitColor: .primaryGreen)
            viewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .primaryGreen)]
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
