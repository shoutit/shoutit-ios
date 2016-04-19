//
//  ChangeEmailSettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

final class ChangeEmailSettingsFormViewModel: SettingsFormViewModel {
    
    private let disposeBag = DisposeBag()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let successSubject: PublishSubject<Void> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    
    let title = NSLocalizedString("Change email", comment: "")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        let newPasswordCell = SettingsFormCellViewModel.TextField(value: nil, type: .NewEmail)
        let changeButtonCell = SettingsFormCellViewModel.Button(title: NSLocalizedString("Change email", comment: ""), action: changeEmail)
        cellViewModels = [newPasswordCell, changeButtonCell]
    }
    
    private func changeEmail() {
        
        guard let username = Account.sharedInstance.loggedUser?.username else {
            preconditionFailure()
        }
        var newEmail: String?
        for case .TextField(let value, .NewEmail) in cellViewModels {
            newEmail = value
        }
        
        if case .Invalid(let errors) = Validator.validateEmail(newEmail) {
            errorSubject.onNext(errors[0])
            return
        }
        
        let params = EmailParams(email: newEmail)
        APIProfileService.editEmailForUserWithUsername(username, withEmailParams: params)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let user):
                    Account.sharedInstance.loggedUser = user
                    self?.successSubject.onNext()
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
