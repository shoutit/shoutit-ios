//
//  ChangeEmailSettingsFormViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class ChangeEmailSettingsFormViewModel: SettingsFormViewModel {
    
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    
    let title = NSLocalizedString("Change email", comment: "")
    var cellViewModels: [SettingsFormCellViewModel] = []
    
    init() {
        let newPasswordCell = SettingsFormCellViewModel.TextField(value: nil, placeholder: NSLocalizedString("New email", comment: ""), secureTextEntry: true, validator: Validator.validateEmail)
        let changeButtonCell = SettingsFormCellViewModel.Button(title: NSLocalizedString("Change email", comment: ""), action: changeEmail)
        cellViewModels = [newPasswordCell, changeButtonCell]
    }
    
    private func changeEmail() {
        
    }
}
