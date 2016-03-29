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
        let facebookLoginManager = FBSDKLoginManager()
        facebookLoginManager.logInWithReadPermissions(Constants.Facebook.loginReadPermissions, fromViewController: viewController) { (loginResult, error) -> Void in
            
            if let error = error {
                self.errorSubject.onNext(error)
                self.progressHUDSubject.onNext(false)
                return
            }
            
            if loginResult.isCancelled {
                self.progressHUDSubject.onNext(false)
            }
            
            if let token = loginResult.token {
                let params = FacebookLoginParams(token: token.tokenString)
                self.authenticateWithParameters(params)
            }
        }
    }
    
    // MARK: - Private
    
    private func authenticateWithParameters(params: AuthParams) {
        
        let observable: Observable<(AuthData, LoggedUser)> = APIAuthService.getOAuthToken(params)
        observable
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
        
        if let serverAuthCode = user?.authentication.idToken {
            let params = GoogleLoginParams(gplusCode: serverAuthCode)
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

