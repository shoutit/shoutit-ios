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

protocol LoginMethodChoiceViewControllerFlowDelegate: class, FlowController, HelpDisplayable, FeedbackDisplayable, AboutDisplayable, LoginScreenDisplayable {}

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
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title view
        navigationItem.titleView = UIImageView(image: UIImage.navBarLogoImage())
        
        // setup
        setupRX()
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
        
        viewModel.loginSuccessSubject.subscribeNext { (isNewSignup) -> Void in
            if isNewSignup {
                // show post signup
            } else {
                // show main interface
            }
        }.addDisposableTo(disposeBag)
    }
}
