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
    
    let loginSuccessSubject = PublishSubject<Bool>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<NSError>()
    
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
        
        APIAuthService.getOauthToken(params) { (result: Result<(AuthData, LoggedUser), NSError>) -> Void in
            self.progressHUDSubject.onNext(false)
            switch result {
            case .Success((let authData, let user)):
                try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                self.loginSuccessSubject.onNext(authData.isNewSignUp)
            case .Failure(let error):
                self.errorSubject.onNext(error)
            }
        }
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

