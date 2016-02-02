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
import ResponsiveLabel

final class SignupViewController: UIViewController {
    
    typealias _PatternTapResponder = @convention(block) (String!) -> Void
    
    // UI
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var signupButton: CustomUIButton!
    @IBOutlet weak var termsAndPolicyLabel: ResponsiveLabel!
    @IBOutlet weak var switchToLoginButton: UIButton!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // navigation
    weak var flowDelegate: LoginWithEmailViewControllerFlowDelegate?
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupTermsAndPolicyLabel()
        setupSwitchToLoginLabel()
        setupTextFields()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        switchToLoginButton
            .rx_tap
            .subscribeNext{[unowned self] in
                self.delegate?.presentLogin()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupTermsAndPolicyLabel() {
        
        // get text
        let text = NSLocalizedString("By Proceeding you also agree to Shoutit’s Terms of Service and Privacy Policy.", comment: "Signup screen terms and policy message message")
        let termsClickableText = NSLocalizedString("Terms of Service", comment: "Signup screen part of terms and condition message. Must match that in whole text")
        let privacyPolicyClickableText = NSLocalizedString("Privacy Policy", comment: "Signup screen part of terms and condition message. Must match that in whole text")
        
        // create paragraph style
        let paragrapghStyle = NSMutableParagraphStyle()
        paragrapghStyle.alignment = .Center
        
        // create attibuted string
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSParagraphStyleAttributeName : paragrapghStyle])
        
        // get ranges
        let termsRange = (text as NSString).rangeOfString(termsClickableText)
        let policyRange = (text as NSString).rangeOfString(privacyPolicyClickableText)
        
        // create tap responders
        let termsResponder: _PatternTapResponder = {[weak self] (_) in
            self?.flowDelegate?.showTermsAndConditions()
        }
        let policyResponder: _PatternTapResponder = {[weak self] (_) in
            self?.flowDelegate?.showPrivacyPolicy()
        }
        
        // set attributed
        attributedString.setAttributes([RLTapResponderAttributeName : unsafeBitCast(termsResponder, AnyObject.self), NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)], range: termsRange)
        attributedString.setAttributes([RLTapResponderAttributeName : unsafeBitCast(policyResponder, AnyObject.self), NSUnderlineStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)], range: policyRange)
        
        // assign string
        termsAndPolicyLabel.setAttributedText(attributedString, withTruncation: false)
    }
    
    private func setupSwitchToLoginLabel() {
        
        let text = NSLocalizedString("Have an account? Log in", comment: "Signup view")
        let loginText = NSLocalizedString("Log in", comment: "Signup view. Should be the same as whole text's part")
        
        
        let attributedString = NSMutableAttributedString(string: text)
        
        // get attributes for login
        let range = (text as NSString).rangeOfString(loginText)
        let attributes = [NSForegroundColorAttributeName : UIColor(shoutitColor: .PrimaryGreen)]
        
        // modify attributed string
        attributedString.setAttributes(attributes, range: range)
        
        // assign
        switchToLoginButton.setAttributedTitle(attributedString, forState: .Normal)
    }
    
    private func setupTextFields() {
        
        [nameTextField, emailTextField, passwordTextField].forEach {textField in
            textField.font = UIFont.systemFontOfSize(18.0)
            textField.textColor = MaterialColor.black
            
            textField.titleLabel = UILabel()
            textField.titleLabel!.font = RobotoFont.mediumWithSize(12)
            textField.titleLabelColor = MaterialColor.grey.lighten1
            textField.titleLabelActiveColor = UIColor(shoutitColor: .PrimaryGreen)
            textField.clearButtonMode = .WhileEditing
        }
    }
}