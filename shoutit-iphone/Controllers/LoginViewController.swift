//
//  LoginViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material
import MBProgressHUD

final class LoginViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var emailTextField: FormTextField!
    @IBOutlet weak var passwordTextField: FormTextField!
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var switchToSignupButton: UIButton!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupSwitchToSignupLabel()
        
        Appsee.markView(asSensitive: emailTextField)
        Appsee.markView(asSensitive: passwordTextField)
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        let loginActionFilterClosure: (Void) -> Bool = {[unowned self] in
            
            for validationResult in [ShoutitValidator.validateUniversalEmailOrUsernameField(self.emailTextField.text)] {
                if case .invalid(let errors) = validationResult {
                    if let error = errors.first {
                        self.delegate?.showLoginErrorMessage(error.message)
                    }
                    return false
                }
            }
            
            return true
        }
        
        // response to user actions
        switchToSignupButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.delegate?.presentSignup()
        }).addDisposableTo(disposeBag)
        
        loginButton.rx.tap.filter(loginActionFilterClosure).subscribe(onNext: { [unowned self] in
            if let view = self.parent?.view {
                MBProgressHUD.showAdded(to: view, animated: true)
            }
            self.viewModel.loginWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!)
        }).addDisposableTo(disposeBag)
        
        forgotPasswordButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.delegate?.presentResetPassword()
            })
            .addDisposableTo(disposeBag)
        
        // on return actions
        emailTextField.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }).addDisposableTo(disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidEndOnExit).filter(loginActionFilterClosure).subscribe(onNext: { [unowned self] in
            if let view = self.parent?.view {
                MBProgressHUD.showAdded(to: view, animated: true)
            }
            self.viewModel.loginWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!)
        }).addDisposableTo(disposeBag)
        
        // validation
        emailTextField.addValidator(ShoutitValidator.validateUniversalEmailOrUsernameField, withDisposeBag: disposeBag)
    }
    
    fileprivate func setupSwitchToSignupLabel() {
        
        let text = NSLocalizedString("New to Shoutit? Sign up", comment: "Signup view")
        let loginText = NSLocalizedString("Sign up", comment: "Signup view. Should be the same as whole text's part")
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // get attributes for login
        let range = (text as NSString).range(of: loginText)
        let attributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .primaryGreen)]
        
        // modify attributed string
        attributedString.setAttributes(attributes, range: range)
        
        // assign
        switchToSignupButton.setAttributedTitle(attributedString, for: UIControlState())
    }
}
