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
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title view
        navigationItem.titleView = UIImageView(image: UIImage.navBarLogoImage())
        
        // configure google client
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // setup
        setupRX()
    }
    
    override func dismiss() {
        if let navigationController = self.navigationController where navigationController.viewControllers[0] !== self {
            pop()
        } else {
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // user actions observers
        loginWithFacebookButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.viewModel.loginWithFacebookFromViewController(self)
            }
            .addDisposableTo(disposeBag)
        
        loginWithGoogleButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.viewModel.loginWithGoogle()
            }
            .addDisposableTo(disposeBag)
        
        loginWithEmailButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.flowDelegate?.showLoginWithEmail()
            }
            .addDisposableTo(disposeBag)
        
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
        
        // view model observers
        
        viewModel.errorSubject.subscribeNext {[weak self] (error) -> Void in
            self?.showError(error)
        }.addDisposableTo(disposeBag)
        
        viewModel.loginSuccessSubject.subscribeNext {[weak self] (isNewSignup) -> Void in
            if isNewSignup {
                self?.flowDelegate?.showPostSignupInterests()
            } else {
                self?.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
        }.addDisposableTo(disposeBag)
        
        viewModel.progressHUDSubject.subscribeNext{[weak self](show) in
            if show {
                MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
            } else {
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
            }
        }.addDisposableTo(disposeBag)
    }
}

extension LoginMethodChoiceViewController: GIDSignInUIDelegate {
    
    func signIn(signIn: GIDSignIn!,
         presentViewController viewController: UIViewController!) {
        if let viewController = viewController as? UINavigationController {
            viewController.navigationBar.tintColor = UIColor(shoutitColor: .PrimaryGreen)
            viewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .PrimaryGreen)]
        }
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
         dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
