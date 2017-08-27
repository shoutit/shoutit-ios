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
import ShoutitKit

final class LoginWithEmailViewModel {
    
    let loginSuccessSubject = PublishSubject<Bool>()
    let successSubject = PublishSubject<String>()
    let errorSubject = PublishSubject<Error>()
    let disposeBag = DisposeBag()
    
    func loginWithEmail(_ email: String, password: String) {
        let loginParams = LoginParams(email: email, password: password, mixPanelDistinctId: MixpanelHelper.getDistictId(), currentUserCoordinates: LocationManager.sharedInstance.currentLocation.coordinate)
        authenticateWithParameters(loginParams)
    }
    
    func signupWithName(_ name: String, email: String, password: String, invitationCode: String?) {
        let signupParams = SignupParams(name: name, email: email, password: password, mixPanelDistinctId: MixpanelHelper.getDistictId(), currentUserCoordinates: LocationManager.sharedInstance.currentLocation.coordinate, invitationCode: invitationCode)
        authenticateWithParameters(signupParams)
    }
    
    func resetPasswordForEmail(_ email: String) {
        let resetPasswordParams = ResetPasswordParams(email: email)
        APIAuthService.resetPassword(resetPasswordParams).subscribe {(event) in
            switch event {
            case .next(let success):
                self.successSubject.onNext(success.message)
            case .error(let error):
                self.errorSubject.onNext(error)
            case .completed:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    
    func authenticateWithParameters(_ params: AuthParams) {
        
        let observable: Observable<(AuthData, DetailedUserProfile)> = APIAuthService.getOAuthToken(params)
        observable
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let authData, let user):
                    try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                    self?.loginSuccessSubject.onNext(authData.isNewSignUp)
                case .error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func authenticatePageWithParameters(_ params: AuthParams) {
        
        let observable: Observable<(AuthData, DetailedPageProfile)> = APIAuthService.getOAuthToken(params)
        observable
            .subscribe {[weak self] (event) in
                switch event {
                case .next(let authData, let user):
                    try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                    self?.loginSuccessSubject.onNext(authData.isNewSignUp)
                case .error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
