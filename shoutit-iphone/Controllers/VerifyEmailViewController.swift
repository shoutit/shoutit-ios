//
//  VerifyEmailViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material
import MBProgressHUD

class VerifyEmailViewController: UIViewController {
    
    var viewModel: VerifyEmailViewModel!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var emailTextField: BorderedMaterialTextField!
    @IBOutlet weak var resendButton: CustomUIButton!
    @IBOutlet weak var verifyButton: CustomUIButton!
    @IBOutlet weak var bottomViewToBottomLayoutGuideConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupKeyboardNotifcationListenerForBottomLayoutGuideConstraint(bottomViewToBottomLayoutGuideConstraint)
        setupTextField()
        setupRX()
    }
    
    deinit {
        removeKeyboardNotificationListeners()
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // buttons
        resendButton
            .rx_tap
            .asDriver()
            .driveNext {
                
            }
            .addDisposableTo(disposeBag)
        
        verifyButton
            .rx_tap
            .asDriver()
            .driveNext {
                
            }
            .addDisposableTo(disposeBag)
        
        // validation
        emailTextField.addValidator(Validator.validateUniversalEmailOrUsernameField, withDisposeBag: disposeBag)
    }
    
    private func setupTextField() {
        
        emailTextField.font = UIFont.systemFontOfSize(18.0)
        emailTextField.textColor = MaterialColor.black
            
        emailTextField.titleLabel = UILabel()
        emailTextField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        emailTextField.titleLabelColor = MaterialColor.grey.lighten1
        emailTextField.titleLabelActiveColor = UIColor(shoutitColor: .ShoutitLightBlueColor)
        emailTextField.clearButtonMode = .WhileEditing
            
        emailTextField.detailLabel = UILabel()
        emailTextField.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .Medium)
        emailTextField.detailLabelActiveColor = MaterialColor.red.accent3
    }
}
