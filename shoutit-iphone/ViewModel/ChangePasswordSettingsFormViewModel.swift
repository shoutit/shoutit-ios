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
    
    private let disposeBag = DisposeBag()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let successSubject: PublishSubject<Success> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    
    let title = NSLocalizedString("Change password", comment: "")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        
        let oldPasswordCell = SettingsFormCellViewModel.TextField(value: nil, type: .OldPassword)
        let newPasswordCell = SettingsFormCellViewModel.TextField(value: nil, type: .NewPassword)
        let verifyPasswordCell = SettingsFormCellViewModel.TextField(value: nil, type: .VerifyPassword)
        let changeButtonCell = SettingsFormCellViewModel.Button(title: NSLocalizedString("Change password", comment: ""), action: changePassword)
        
        if case .Logged(let user)? = Account.sharedInstance.loginState where user.isPasswordSet == true {
            cellViewModels = [oldPasswordCell, newPasswordCell, verifyPasswordCell, changeButtonCell]
        } else {
            cellViewModels = [newPasswordCell, verifyPasswordCell, changeButtonCell]
        }
    }
    
    private func changePassword() {
        
        var oldPassword: String?
        var newPassword: String?
        var newPassword2: String?
        
        for case let .TextField(value, type) in cellViewModels {
            switch type {
            case .NewPassword: newPassword = value
            case .VerifyPassword: newPassword2 = value
            case .OldPassword: oldPassword = value
            default: break
            }
        }
        
        if case .Invalid(let errors) = ShoutitValidator.validatePassword(newPassword) {
            errorSubject.onNext(errors[0])
            return
        }
        
        guard let new = newPassword, let new2 = newPassword2 else {
            errorSubject.onNext(LightError(userMessage: NSLocalizedString("Fields must not be empty", comment: "")))
            return
        }
        
        let params = ChangePasswordParams(oldPassword: oldPassword, newPassword: new, newPassword2: new2)
        APIAuthService.changePasswordWithParams(params)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let success):
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
