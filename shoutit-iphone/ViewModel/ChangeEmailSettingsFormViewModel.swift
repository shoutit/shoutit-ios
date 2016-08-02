//
//  ChangeEmailSettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class ChangeEmailSettingsFormViewModel: SettingsFormViewModel {
    
    private let disposeBag = DisposeBag()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let successSubject: PublishSubject<Success> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    
    let title = NSLocalizedString("Change email", comment: "Change Email screen title")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        let newPasswordCell = SettingsFormCellViewModel.TextField(value: nil, type: .NewEmail)
        let changeButtonCell = SettingsFormCellViewModel.Button(title: NSLocalizedString("Change email", comment: "Change Email Button Title"), action: changeEmail)
        cellViewModels = [newPasswordCell, changeButtonCell]
    }
    
    private func changeEmail() {
        let user: DetailedProfile
        switch Account.sharedInstance.loginState {
        case .Logged(let logged)?:
            user = logged
        case .Page(_, let page)?:
            user = page
        default:
            fatalError()
        }
        var newEmail: String?
        for case .TextField(let value, .NewEmail) in cellViewModels {
            newEmail = value
        }
        
        if case .Invalid(let errors) = ShoutitValidator.validateEmail(newEmail) {
            errorSubject.onNext(errors[0])
            return
        }
        
        let params = EmailParams(email: newEmail)
        APIProfileService.editEmailForUserWithUsername(user.username, withEmailParams: params)
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let user):
                    Account.sharedInstance.updateUserWithModel(user)
                    self?.successSubject.onNext(Success(message: NSLocalizedString("Email Changed", comment: "Change Email Success Message")))
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
