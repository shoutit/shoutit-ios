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
        case NewPassword
        case VerifyPassword
        case OldPassword
        case NewEmail
        
        var placeholder: String {
            switch self {
            case .NewEmail: return NSLocalizedString("New email", comment: "")
            case .NewPassword: return NSLocalizedString("New Password", comment: "")
            case .VerifyPassword: return NSLocalizedString("Verify New Password", comment: "")
            case .OldPassword: return NSLocalizedString("Current Password", comment: "")
            }
        }
        
        var secureTextEntry: Bool {
            switch self {
            case .NewPassword, .VerifyPassword, .OldPassword: return true
            default: return false
            }
        }
        
        var validator: (String -> ValidationResult)? {
            switch self {
            case .NewPassword: return ShoutitValidator.validatePassword
            case .NewEmail: return ShoutitValidator.validateEmail
            default: return nil
            }
        }
    }
    
    case TextField(value: String?, type: TextFieldType)
    case Button(title: String, action: (Void -> Void))
}
