//
//  SignupViewController.swift
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

final class SignupViewController: UITableViewController {
    
    typealias _PatternTapResponder = @convention(block) (String!) -> Void
    
    // UI
    @IBOutlet weak var nameTextField: FormTextField!
    @IBOutlet weak var emailTextField: FormTextField!
    @IBOutlet weak var passwordTextField: FormTextField!
    @IBOutlet weak var signupButton: CustomUIButton!
    @IBOutlet weak var termsAndPolicyLabel: ResponsiveLabel!
    @IBOutlet weak var switchToLoginButton: UIButton!
    @IBOutlet weak var createPageButton: UIButton!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // navigation
    weak var flowDelegate: FlowController?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupTermsAndPolicyLabel()
        setupSwitchToLoginLabel()
        setupCreatePageLabel()
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        let signupActionFilterClosure: (Void) -> Bool = {[unowned self] in
            
            for validationResult in [ShoutitValidator.validateName(self.nameTextField.text), ShoutitValidator.validateEmail(self.emailTextField.text), ShoutitValidator.validatePassword(self.passwordTextField.text)] {
                if case .invalid(let errors) = validationResult {
                    if let error = errors.first {
                        self.delegate?.showLoginErrorMessage(error.message)
                    }
                    return false
                }
            }
            
            return true
        }
        
        // user actions
        switchToLoginButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.delegate?.presentLogin()
            }
            .addDisposableTo(disposeBag)
        
        createPageButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.delegate?.presentCreatePage()
            }
            .addDisposableTo(disposeBag)
        
        signupButton
            .rx_tap
            .filter(signupActionFilterClosure).subscribeNext{
                MBProgressHUD.showAdded(to: self.parent?.view, animated: true)
                self.viewModel.signupWithName(self.nameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, invitationCode: Account.sharedInstance.invitationCode)
            }
            .addDisposableTo(disposeBag)
        
        // return button
        nameTextField.rx_controlEvent(.editingDidEndOnExit).subscribeNext{[weak self] in
            self?.emailTextField.becomeFirstResponder()
        }.addDisposableTo(disposeBag)
        
        emailTextField.rx_controlEvent(.editingDidEndOnExit).subscribeNext{[weak self] in
            self?.passwordTextField.becomeFirstResponder()
        }.addDisposableTo(disposeBag)
        
        passwordTextField.rx_controlEvent(.editingDidEndOnExit).filter(signupActionFilterClosure).subscribeNext{[unowned self] in
            MBProgressHUD.showAdded(to: self.parent?.view, animated: true)
            self.viewModel.signupWithName(self.nameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, invitationCode: Account.sharedInstance.invitationCode)
        }.addDisposableTo(disposeBag)
        
        // add validators
        nameTextField.addValidator(ShoutitValidator.validateName, withDisposeBag: disposeBag)
        emailTextField.addValidator(ShoutitValidator.validateEmail, withDisposeBag: disposeBag)
        passwordTextField.addValidator(ShoutitValidator.validatePassword, withDisposeBag: disposeBag)
    }
    
    fileprivate func setupTermsAndPolicyLabel() {
        
        // get text
        let text = NSLocalizedString("By Proceeding you also agree to Shoutit’s Terms of Service and Privacy Policy.", comment: "Signup screen terms and policy message message")
        let termsClickableText = NSLocalizedString("Terms of Service", comment: "Signup screen part of terms and condition message. Must match that in whole text")
        let privacyPolicyClickableText = NSLocalizedString("Privacy Policy", comment: "Signup screen part of terms and condition message. Must match that in whole text")
        
        // create paragraph style
        let paragrapghStyle = NSMutableParagraphStyle()
        paragrapghStyle.alignment = .center
        
        // create attibuted string
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSParagraphStyleAttributeName : paragrapghStyle])
        
        // get ranges
        let termsRange = (text as NSString).range(of: termsClickableText)
        let policyRange = (text as NSString).range(of: privacyPolicyClickableText)
        
        // create tap responders
        let termsResponder: _PatternTapResponder = {[weak self] (_) in
            self?.flowDelegate?.showTermsAndConditions()
        }
        let policyResponder: _PatternTapResponder = {[weak self] (_) in
            self?.flowDelegate?.showPrivacyPolicy()
        }
        
        // set attributed
        attributedString.setAttributes([RLTapResponderAttributeName : unsafeBitCast(termsResponder, to: AnyObject.self), NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)], range: termsRange)
        attributedString.setAttributes([RLTapResponderAttributeName : unsafeBitCast(policyResponder, to: AnyObject.self), NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)], range: policyRange)
        
        // assign string
        termsAndPolicyLabel.setAttributedText(attributedString, withTruncation: false)
    }
    
    fileprivate func setupSwitchToLoginLabel() {
        
        let text = NSLocalizedString("Have an account? Log in", comment: "Signup view")
        let loginText = NSLocalizedString("Log in", comment: "Signup view. Should be the same as whole text's part")
        
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // get attributes for login
        let range = (text as NSString).range(of: loginText)
        let attributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .primaryGreen)]
        
        // modify attributed string
        attributedString.setAttributes(attributes, range: range)
        
        // assign
        switchToLoginButton.setAttributedTitle(attributedString, for: UIControlState())
    }
    
    fileprivate func setupCreatePageLabel() {
        
        let text = NSLocalizedString("Create a Page for brand or business.", comment: "Signup view")
        let loginText = NSLocalizedString("Create a Page", comment: "Signup view. Should be the same as whole text's part")
        
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // get attributes for login
        let range = (text as NSString).range(of: loginText)
        let attributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .primaryGreen)]
        
        // modify attributed string
        attributedString.setAttributes(attributes, range: range)
        
        // assign
        createPageButton.setAttributedTitle(attributedString, for: UIControlState())
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
}
