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

extension Error {
    public var message: String {
        return self.localizedDescription
    }
}

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
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
    }
    
    fileprivate func setupRX() {
        
        backToLoginButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.delegate?.presentLogin()
            })
            .addDisposableTo(disposeBag)
        
        resetPasswordButton.rx.tap.filter {
            if case .invalid(let errors) = ShoutitValidator.validateEmail(self.emailTextField.text) {
                if let error = errors.first {
                    self.delegate?.showLoginErrorMessage(error.message)
                }
                return false
            }
            
            return true
            }
            .subscribe(onNext: { [unowned self] in
                if let view = self.parent?.view {
                    MBProgressHUD.showAdded(to: view, animated: true)
                }
                self.viewModel.resetPasswordForEmail(self.emailTextField.text!)
            })
            .addDisposableTo(disposeBag)
        
        // add validators
        emailTextField.addValidator(ShoutitValidator.validateEmail, withDisposeBag: disposeBag)
    }
}
