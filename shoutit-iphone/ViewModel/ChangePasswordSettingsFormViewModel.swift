//
//  ChangePasswordSettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class ChangePasswordSettingsFormViewModel: SettingsFormViewModel {
    
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    
    let title = NSLocalizedString("Change password", comment: "")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        let oldPasswordCell = SettingsFormCellViewModel.TextField(value: nil, placeholder: NSLocalizedString("Current Password", comment: ""), secureTextEntry: true, validator: nil)
        let newPasswordCell = SettingsFormCellViewModel.TextField(value: nil, placeholder: NSLocalizedString("New Password", comment: ""), secureTextEntry: true, validator: Validator.validatePassword)
        let verifyPasswordCell = SettingsFormCellViewModel.TextField(value: nil, placeholder: NSLocalizedString("Verify New Password", comment: ""), secureTextEntry: true, validator: nil)
        let changeButtonCell = SettingsFormCellViewModel.Button(title: NSLocalizedString("Change password", comment: ""), action: changePassword)
        
        if let isPasswordSet = Account.sharedInstance.loggedUser?.isPasswordSet where isPasswordSet == true {
            cellViewModels = [oldPasswordCell, newPasswordCell, verifyPasswordCell, changeButtonCell]
        } else {
            cellViewModels = [newPasswordCell, verifyPasswordCell, changeButtonCell]
        }
    }
    
    private func changePassword() {
        
    }
}
