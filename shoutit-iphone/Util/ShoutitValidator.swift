//
//  Validator.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import ShoutitKit
import Validator

//extension ValidationError: ShoutitError {
//    public var userMessage: String {
//        return message
//    }
//}

struct ShoutitValidator {
    
    enum ValidationError: ValidationErrorType {
        case invalidEmail
        case invalidEmailOrUsername
        case invalidFirstname
        case invalidLastname
        case invalidPassword
        
        var message: String {
            switch self {
            case .invalidEmail:
                return NSLocalizedString("Enter valid email", comment: "Enter valid email.")
            case .invalidEmailOrUsername:
                return NSLocalizedString("Enter valid email / username", comment: "Enter valid email / username")
            case .invalidFirstname:
                return NSLocalizedString("First name should have between 2 and 30 characters", comment: "Enter valid first name")
            case .invalidLastname:
                return NSLocalizedString("Last name name should have between 1 and 30 characters", comment: "Enter valid last name")
            case .invalidPassword:
                return NSLocalizedString("Password should have between 6 and 20 characters", comment: "Password characters number should be between 6-20")
            }
        }
    }
    
    static func validateUniversalEmailOrUsernameField(_ string: String?) -> ValidationResult {
        
        let error = ValidationError.invalidEmailOrUsername
        
        guard let string = string else {
            return .invalid([error])
        }
        
        let emailValidationRule = ValidationRulePattern(pattern: .EmailAddress, failureError: error)
        let usernameValidationRule = ValidationRulePattern(pattern: "^[a-z0-9A-Z_-]{2,20}$", failureError: error)
        
        if case .valid = string.validate(rule: usernameValidationRule) {
            return .valid
        }
        
        return string.validate(rule: emailValidationRule)
    }
    
    
    static func validateEmail(_ email: String?) -> ValidationResult {
        
        let error = ValidationError.invalidEmail
        
        guard let email = email else {
            return .invalid([error])
        }
        
        let emailValidationRule = ValidationRulePattern(pattern: .EmailAddress, failureError: error)
        return email.validate(rule: emailValidationRule)
    }
    
    static func validatePassword(_ password: String?) -> ValidationResult {
        
        let error = ValidationError.invalidPassword
        
        guard let password = password else {
            return .invalid([error])
        }
        
        let passwordValidationRule = ValidationRulePattern(pattern: "^.{6,20}$", failureError: error)
        return password.validate(rule: passwordValidationRule)
    }
    
    static func validateName(_ name: String?) -> ValidationResult {
        
        let error = ValidationError.invalidFirstname
        
        guard let name = name else {
            return .invalid([error])
        }
        
        let nameValidationRule = ValidationRulePattern(pattern: "^.{2,30}$", failureError: error)
        return name.validate(rule: nameValidationRule)
    }
    
    static func validateFirstname(_ firstname: String?) -> ValidationResult {
        
        let error = ValidationError.invalidFirstname
        
        guard let firstname = firstname else {
            return .invalid([error])
        }
        
        let firstnameValidationRule = ValidationRulePattern(pattern: "^.{2,30}$", failureError: error)
        return firstname.validate(rule: firstnameValidationRule)
    }
    
    static func validateLastname(_ lastname: String?) -> ValidationResult {
        
        let error = ValidationError.invalidLastname
        
        guard let lastname = lastname else {
            return .invalid([error])
        }
        
        let lastnameValidationRule = ValidationRulePattern(pattern: "^.{1,30}$", failureError: error)
        return lastname.validate(rule: lastnameValidationRule)
    }
}

