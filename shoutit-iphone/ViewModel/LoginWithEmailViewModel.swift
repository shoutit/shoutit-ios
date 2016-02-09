//
//  LoginWithEmailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 02.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginWithEmailViewModel {
    
    let loginSuccessSubject = PublishSubject<Bool>()
    let successSubject = PublishSubject<String>()
    let errorSubject = PublishSubject<NSError>()
    
    func loginWithEmail(email: String, password: String) {
        let loginParams = LoginParams(email: email, password: password)
        authenticateWithParameters(loginParams)
    }
    
    func signupWithName(name: String, email: String, password: String) {
        let signupParams = SignupParams(name: name, email: email, password: password)
        authenticateWithParameters(signupParams)
    }
    
    func resetPasswordForEmail(email: String) {
        let resetPasswordParams = ResetPasswordParams(email: email)
        APIAuthService.resetPassword(resetPasswordParams) { (result) -> Void in
            switch result {
            case .Success(let success):
                self.successSubject.onNext(success.message)
            case .Failure(let error):
                self.errorSubject.onNext(error)
            }
        }
    }
    
    private func authenticateWithParameters(params: AuthParams) {
        
        APIAuthService.getOauthToken(params) { (result) -> Void in
            switch result {
            case .Success(let authData):
                try! Account.sharedInstance.loginUserWithAuthData(authData)
                self.loginSuccessSubject.onNext(authData.isNewSignUp)
            case .Failure(let error):
                self.errorSubject.onNext(error)
            }
        }
    }
}