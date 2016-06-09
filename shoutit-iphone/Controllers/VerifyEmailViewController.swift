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

final class VerifyEmailViewController: UIViewController {
    
    typealias VerifyEmailSuccessBlock = (String -> Void)?
    
    var viewModel: VerifyEmailViewModel!
    
    var successBlock: VerifyEmailSuccessBlock?
    
    // RX
    private let disposeBag = DisposeBag()
    
    // UI
    @IBOutlet weak var emailTextField: BorderedMaterialTextField!
    @IBOutlet weak var resendButton: CustomUIButton!
    @IBOutlet weak var verifyButton: CustomUIButton!
    @IBOutlet weak var bottomViewToBottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
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
            .driveNext{ [unowned self] in
                self.viewModel.verifyEmail()
            }
            .addDisposableTo(disposeBag)
        
        verifyButton
            .rx_tap
            .asDriver()
            .driveNext {[unowned self] in
                self.viewModel.updateUser()
            }
            .addDisposableTo(disposeBag)
        
        cancelBarButtonItem
            .rx_tap
            .asDriver()
            .driveNext {[weak self] in
                self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        // subjects
        
        viewModel.progressSubject
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (show) in
                if show {
                    MBProgressHUD.showHUDAddedTo(self?.view, animated: true)
                } else {
                    MBProgressHUD.hideHUDForView(self?.view, animated: true)
                }
            }
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (message) in
                let block = self?.successBlock
                self?.navigationController?.dismissViewControllerAnimated(true, completion: {
                    block??(message)
                })
            }
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (error) in
                self?.showError(error)
            }
            .addDisposableTo(disposeBag)
        
        // text field
        emailTextField.rx_text.bindTo(viewModel.email).addDisposableTo(disposeBag)
        
        // validation
        emailTextField.addValidator(ShoutitValidator.validateEmail, withDisposeBag: disposeBag)
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
        
        emailTextField.text = viewModel.email.value
    }
}
