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

protocol LoginMethodChoiceViewControllerFlowDelegate: class, FlowController, HelpDisplayable, FeedbackDisplayable, AboutDisplayable, LoginScreenDisplayable, PostSignupDisplayable, LoginFinishable {}

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
    weak var flowDelegate: LoginMethodChoiceViewControllerFlowDelegate?
    
    // rx
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title view
        navigationItem.titleView = UIImageView(image: UIImage.navBarLogoImage())
        
        // configure google client
        GIDSignIn.sharedInstance().clientID = Constants.Google.clientID
        GIDSignIn.sharedInstance().serverClientID = Constants.Google.serverClientID
        GIDSignIn.sharedInstance().allowsSignInWithBrowser = false
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().allowsSignInWithWebView = true
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/userinfo.email"]
        
        // setup
        setupRX()
    }
    
    func dismiss() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            self?.presentViewController(alertController, animated: true, completion: nil)
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
