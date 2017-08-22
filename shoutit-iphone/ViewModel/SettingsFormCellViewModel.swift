//
//  SettingsFormCellViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 06.04.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Validator

enum SettingsFormCellViewModel {
    
    enum TextFieldType {
        case newPassword
        case verifyPassword
        case oldPassword
        case newEmail
        
        var placeholder: String {
            switch self {
            case .newEmail: return NSLocalizedString("New email", comment: "")
            case .newPassword: return NSLocalizedString("New Password", comment: "")
            case .verifyPassword: return NSLocalizedString("Verify New Password", comment: "")
            case .oldPassword: return NSLocalizedString("Current Password", comment: "")
            }
        }
        
        var secureTextEntry: Bool {
            switch self {
            case .newPassword, .verifyPassword, .oldPassword: return true
            default: return false
            }
        }
        
        var validator: ((String) -> ValidationResult)? {
            switch self {
            case .newPassword: return ShoutitValidator.validatePassword
            case .newEmail: return ShoutitValidator.validateEmail
            default: return nil
            }
        }
    }
    
    case textField(value: String?, type: TextFieldType)
    case button(title: String, action: ((Void) -> Void))
}
