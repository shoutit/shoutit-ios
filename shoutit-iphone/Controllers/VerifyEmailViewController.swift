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
    
    typealias VerifyEmailSuccessBlock = ((String) -> Void)?
    
    var viewModel: VerifyEmailViewModel!
    
    var successBlock: VerifyEmailSuccessBlock?
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
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
    
    fileprivate func setupRX() {
        
        // buttons
        resendButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.viewModel.verifyEmail()
            })
            .addDisposableTo(disposeBag)
        
        verifyButton
            .rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] in
                self.viewModel.updateUser()
            })
            .addDisposableTo(disposeBag)
        
        cancelBarButtonItem
            .rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        // subjects
        
        viewModel.progressSubject
            .distinctUntilChanged( { $0 == $1 })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (show) in
                if show {
                    if let view = self?.view {
                            MBProgressHUD.showAdded(to: view, animated: true)
                        }
                } else {
                    if let view = self?.view {
                    MBProgressHUD.hide(for: view, animated: true)
                }
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.successSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (message) in
                let block = self?.successBlock
                self?.navigationController?.dismiss(animated: true, completion: {
                    block??(message)
                })
            })
            .addDisposableTo(disposeBag)
        
        viewModel.errorSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (error) in
                self?.showError(error)
            })
            .addDisposableTo(disposeBag)
        
        // text field
        // ref
//        emailTextField.rx.text.bind(to: viewModel.email).addDisposableTo(disposeBag)
        
        // validation
        emailTextField.addValidator(ShoutitValidator.validateEmail, withDisposeBag: disposeBag)
    }
    
    fileprivate func setupTextField() {
        
        emailTextField.font = UIFont.systemFont(ofSize: 18.0)
        emailTextField.textColor = Material.Color.black
            
        emailTextField.titleLabel = UILabel()
        emailTextField.titleLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .medium)
        emailTextField.titleLabelColor = Material.Color.grey.lighten1
        emailTextField.titleLabelActiveColor = UIColor(shoutitColor: .shoutitLightBlueColor)
        emailTextField.clearButtonMode = .whileEditing
            
        emailTextField.detailLabel = UILabel()
        emailTextField.detailLabel!.font = UIFont.sh_systemFontOfSize(12, weight: .medium)
        emailTextField.detailLabelActiveColor = Material.Color.red.accent3
        
        emailTextField.text = viewModel.email.value
    }
}
