//
//  ChangePasswordSettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class ChangePasswordSettingsFormViewModel: SettingsFormViewModel {
    
    fileprivate let disposeBag = DisposeBag()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let successSubject: PublishSubject<Success> = PublishSubject()
    let errorSubject: PublishSubject<ErrorProtocol> = PublishSubject()
    
    let title = NSLocalizedString("Change password", comment: "Change password screen title")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        
        let oldPasswordCell = SettingsFormCellViewModel.textField(value: nil, type: .oldPassword)
        let newPasswordCell = SettingsFormCellViewModel.textField(value: nil, type: .newPassword)
        let verifyPasswordCell = SettingsFormCellViewModel.textField(value: nil, type: .verifyPassword)
        let changeButtonCell = SettingsFormCellViewModel.button(title: NSLocalizedString("Change password", comment: "Change Password Button Title"), action: changePassword)
        
        if case .logged(let user)? = Account.sharedInstance.loginState, user.isPasswordSet == true {
            cellViewModels = [oldPasswordCell, newPasswordCell, verifyPasswordCell, changeButtonCell]
        } else {
            cellViewModels = [newPasswordCell, verifyPasswordCell, changeButtonCell]
        }
    }
    
    fileprivate func changePassword() {
        
        var oldPassword: String?
        var newPassword: String?
        var newPassword2: String?
        
        for case let .textField(value, type) in cellViewModels {
            switch type {
            case .newPassword: newPassword = value
            case .verifyPassword: newPassword2 = value
            case .oldPassword: oldPassword = value
            default: break
            }
        }
        
        if case .invalid(let errors) = ShoutitValidator.validatePassword(newPassword) {
            errorSubject.onNext(errors[0])
            return
        }
        
        guard let new = newPassword, let new2 = newPassword2 else {
            errorSubject.onNext(LightError(userMessage: NSLocalizedString("Fields must not be empty", comment: "Change Password Empty Fields message")))
            return
        }
        
        let params = ChangePasswordParams(oldPassword: oldPassword, newPassword: new, newPassword2: new2)
        APIAuthService.changePasswordWithParams(params)
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let success):
                    self?.successSubject.onNext(success)
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
