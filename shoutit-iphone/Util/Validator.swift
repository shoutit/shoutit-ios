//
//  Validator.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Validator

enum ValidationError: ValidationErrorType {
    case InvalidEmail
    case InvalidEmailOrUsername
    case InvalidFirstname
    case InvalidLastname
    case InvalidPassword
    
    var message: String {
        switch self {
        case .InvalidEmail:
            return NSLocalizedString("EnterValidMail", comment: "Enter valid email.")
        case .InvalidEmailOrUsername:
            return NSLocalizedString("EnterValidMailOrUsername", comment: "Enter valid email / username")
        case .InvalidFirstname:
            return NSLocalizedString("FirstNameValidationError", comment: "Enter valid first name.")
        case .InvalidLastname:
            return NSLocalizedString("LastNameValidationError", comment: "Enter valid last name.")
        case .InvalidPassword:
            return NSLocalizedString("PasswordValidationError", comment: "Password characters limit should be between 6-20")
        }
    }
}

struct Validator {
    
    static func validateUniversalEmailOrUsernameField(string: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidEmailOrUsername
        
        guard let string = string else {
            return .Invalid([error])
        }
        
        let emailValidationRule = ValidationRulePattern(pattern: .EmailAddress, failureError: error)
        let usernameValidationRule = ValidationRulePattern(pattern: "^[a-z0-9A-Z_-]{2,20}$", failureError: error)
        
        if case .Valid = string.validate(rule: usernameValidationRule) {
            return .Valid
        }
        
        return string.validate(rule: emailValidationRule)
    }
    
    
    static func validateEmail(email: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidEmail
        
        guard let email = email else {
            return .Invalid([error])
        }
        
        let emailValidationRule = ValidationRulePattern(pattern: .EmailAddress, failureError: error)
        return email.validate(rule: emailValidationRule)
    }
    
    static func validatePassword(password: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidPassword
        
        guard let password = password else {
            return .Invalid([error])
        }
        
        let passwordValidationRule = ValidationRulePattern(pattern: "^.{6,20}$", failureError: error)
        return password.validate(rule: passwordValidationRule)
    }
    
    static func validateName(name: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidFirstname
        
        guard let name = name else {
            return .Invalid([error])
        }
        
        let nameValidationRule = ValidationRulePattern(pattern: "^.{2,30}$", failureError: error)
        return name.validate(rule: nameValidationRule)
    }
    
    static func validateFirstname(firstname: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidFirstname
        
        guard let firstname = firstname else {
            return .Invalid([error])
        }
        
        let firstnameValidationRule = ValidationRulePattern(pattern: "^.{2,30}$", failureError: error)
        return firstname.validate(rule: firstnameValidationRule)
    }
    
    static func validateLastname(lastname: String?) -> ValidationResult {
        
        let error = ValidationError.InvalidLastname
        
        guard let lastname = lastname else {
            return .Invalid([error])
        }
        
        let lastnameValidationRule = ValidationRulePattern(pattern: "^.{1,30}$", failureError: error)
        return lastname.validate(rule: lastnameValidationRule)
    }
}
