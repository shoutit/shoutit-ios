//
//  ResetPasswordViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 11.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import Material

class ResetPasswordViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var emailTextField: BorderedMaterialTextField!
    @IBOutlet weak var resetPasswordButton: CustomUIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    // view model
    weak var viewModel: LoginWithEmailViewModel!
    
    // delegate
    weak var delegate: LoginWithEmailViewControllerChildDelegate?
    
    // RX
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupTextFields()
    }
    
    private func setupRX() {
        
        backToLoginButton.rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.delegate?.presentLogin()
            }
            .addDisposableTo(disposeBag)
        
        resetPasswordButton.rx_tap.filter {
            if case .Invalid(let errors) = Validator.validateEmail(self.emailTextField.text) {
                if let error = errors.first {
                    self.delegate?.showErrorMessage(error.message)
                }
                return false
            }
            
            return true
            }
            .subscribeNext{[unowned self] in
                MBProgressHUD.showHUDAddedTo(self.parentViewController?.view, animated: true)
                self.viewModel.resetPasswordForEmail(self.emailTextField.text!)
            }
            .addDisposableTo(disposeBag)
        
        // add validators
        emailTextField.addValidator(Validator.validateEmail, withDisposeBag: disposeBag)
    }
    
    private func setupTextFields() {
        
        [emailTextField].forEach {textField in
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
