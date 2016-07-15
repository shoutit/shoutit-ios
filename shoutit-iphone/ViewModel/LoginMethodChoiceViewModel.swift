//
//  LoginMethodChoiceViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import ShoutitKit

final class LoginMethodChoiceViewModel {
    
    private let disposeBag = DisposeBag()
    let loginSuccessSubject = PublishSubject<Bool>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<ErrorType>()
    
    // MARK: - Actions
    
    func loginWithGoogle() {
        progressHUDSubject.onNext(true)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginWithFacebookFromViewController(viewController: UIViewController) {
        progressHUDSubject.onNext(true)
        Account.sharedInstance.facebookManager
            .requestReadPermissionsFromViewController(FacebookPermissions.loginReadPermissions, viewController: viewController)
            .subscribe { (event) in
                switch event {
                case .Next(let token):
                    let params = FacebookLoginParams(token: token, mixPanelDistinctId: MixpanelHelper.getDistictId(), currentUserCoordinates: LocationManager.sharedInstance.currentLocation.coordinate)
                    self.authenticateWithParameters(params)
                case .Error(LocalError.Cancelled):
                    self.progressHUDSubject.onNext(false)
                case .Error(let error):
                    self.errorSubject.onNext(error)
                    self.progressHUDSubject.onNext(false)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Private
    
    private func authenticateWithParameters(params: AuthParams) {
        
        let observable: Observable<(AuthData, DetailedUserProfile)> = APIAuthService.getOAuthToken(params)
            
            observable
            .observeOn(MainScheduler.instance)
            .subscribe {[weak self] (event) in
                self?.progressHUDSubject.onNext(false)
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

extension LoginMethodChoiceViewModel: GIDSignInDelegate {
    
    @objc func signIn(signIn: GIDSignIn?, didSignInForUser user: GIDGoogleUser?, withError error: NSError?) {
        
        GIDSignIn.sharedInstance().delegate = nil
        
        if let error = error {
            if error.code != -5 {
                GIDSignIn.sharedInstance().signOut()
                errorSubject.onNext(error)
            }
            self.progressHUDSubject.onNext(false)
            return
        }
        
        if let serverAuthCode = user?.serverAuthCode {
            let params = GoogleLoginParams(gplusCode: serverAuthCode, mixPanelDistinctId: MixpanelHelper.getDistictId(), currentUserCoordinates: LocationManager.sharedInstance.currentLocation.coordinate)
            authenticateWithParameters(params)
        }
    }
    
    @objc func signIn(signIn: GIDSignIn?, didDisconnectWithUser user:GIDGoogleUser?,
        withError error: NSError?) {
            GIDSignIn.sharedInstance().delegate = nil
            if let error = error {
                errorSubject.onNext(error)
            }
    }
}

