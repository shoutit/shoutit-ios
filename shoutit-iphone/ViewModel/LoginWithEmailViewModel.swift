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
import Alamofire

class LoginWithEmailViewModel {
    
    let loginSuccessSubject = PublishSubject<Bool>()
    let successSubject = PublishSubject<String>()
    let errorSubject = PublishSubject<ErrorType>()
    let disposeBag = DisposeBag()
    
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
        APIAuthService.resetPassword(resetPasswordParams).subscribe {(event) in
            switch event {
            case .Next(let success):
                self.successSubject.onNext(success.message)
            case .Error(let error):
                self.errorSubject.onNext(error)
            case .Completed:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func authenticateWithParameters(params: AuthParams) {
        
        let observable: Observable<(AuthData, LoggedUser)> = APIAuthService.getOAuthToken(params)
        observable
            .subscribe {[weak self] (event) in
                switch event {
                case .Next(let authData, let user):
                    try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                    self?.loginSuccessSubject.onNext(authData.isNewSignUp)
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}