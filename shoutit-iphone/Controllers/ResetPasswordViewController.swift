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

final class ResetPasswordViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var emailTextField: FormTextField!
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
                    self.delegate?.showLoginErrorMessage(error.message)
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
}
