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
import ResponsiveLabel
import Validator
import MBProgressHUD

class LoginViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var emailTextField: BorderedMaterialTextField!
    @IBOutlet weak var passwordTextField: BorderedMaterialTextField!
    @IBOutlet weak var loginButton: CustomUIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var switchToSignupButton: UIButton!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // navigation
    weak var flowDelegate: LoginWithEmailViewControllerFlowDelegate?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupSwitchToSignupLabel()
        setupTextFields()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        let loginActionFilterClosure: Void -> Bool = {[unowned self] in
            
            for validationResult in [Validator.validateUniversalEmailOrUsernameField(self.emailTextField.text)] {
                if case .Invalid(let errors) = validationResult {
                    if let error = errors.first {
                        self.delegate?.showErrorMessage(error.message)
                    }
                    return false
                }
            }
            
            return true
        }
        
        // response to user actions
        switchToSignupButton.rx_tap.subscribeNext{[weak self] in
            self?.delegate?.presentSignup()
        }.addDisposableTo(disposeBag)
        
        loginButton.rx_tap.filter(loginActionFilterClosure).subscribeNext{[unowned self] in
            MBProgressHUD.showHUDAddedTo(self.parentViewController?.view, animated: true)
            self.viewModel.loginWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!)
        }.addDisposableTo(disposeBag)
        
        forgotPasswordButton.rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.delegate?.presentResetPassword()
            }
            .addDisposableTo(disposeBag)
        
        // on return actions
        emailTextField.rx_controlEvent(.EditingDidEndOnExit).subscribeNext{[weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }.addDisposableTo(disposeBag)
        
        passwordTextField.rx_controlEvent(.EditingDidEndOnExit).filter(loginActionFilterClosure).subscribeNext{[unowned self] in
            MBProgressHUD.showHUDAddedTo(self.parentViewController?.view, animated: true)
            self.viewModel.loginWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!)
        }.addDisposableTo(disposeBag)
        
        // validation
        emailTextField.addValidator(Validator.validateUniversalEmailOrUsernameField, withDisposeBag: disposeBag)
    }
    
    private func setupSwitchToSignupLabel() {
        
        let text = NSLocalizedString("New to Shoutit? Sign up", comment: "Signup view")
        let loginText = NSLocalizedString("Sign up", comment: "Signup view. Should be the same as whole text's part")
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // get attributes for login
        let range = (text as NSString).rangeOfString(loginText)
        let attributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .PrimaryGreen)]
        
        // modify attributed string
        attributedString.setAttributes(attributes, range: range)
        
        // assign
        switchToSignupButton.setAttributedTitle(attributedString, forState: .Normal)
    }
    
    private func setupTextFields() {
        
        [emailTextField, passwordTextField].forEach {textField in
            textField.font = UIFont.systemFontOfSize(18.0)
            textField.textColor = MaterialColor.black
            
            textField.titleLabel = UILabel()
            textField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
            textField.titleLabelColor = MaterialColor.grey.lighten1
            textField.titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
            textField.clearButtonMode = .WhileEditing
            
            textField.detailLabel = UILabel()
            textField.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
            textField.detailLabelActiveColor = MaterialColor.red.accent3
        }
    }
}
