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
import FBSDKCoreKit
import FBSDKLoginKit

final class LoginMethodChoiceViewModel {
    
    let loginSuccessSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<NSError>()
    
    // MARK: - Actions
    
    func loginWithGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loginWithFacebookFromViewController(viewController: UIViewController) {
        
        let facebookLoginManager = FBSDKLoginManager()
        facebookLoginManager.logInWithReadPermissions(Constants.Facebook.loginReadPermissions, fromViewController: viewController) { (loginResult, error) -> Void in
            
            if let error = error {
                self.errorSubject.onNext(error)
                return
            }
            
            if let token = loginResult.token {
                let params = APIAuthService.facebookLoginParamsWithToken(token.tokenString)
                self.authenticateWithParameters(params)
            }
        }
    }
    
    // MARK: - Private
    
    private func authenticateWithParameters(params: [String : AnyObject]) {
        
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

extension LoginMethodChoiceViewModel: GIDSignInDelegate {
    
    @objc func signIn(signIn: GIDSignIn?, didSignInForUser user: GIDGoogleUser?, withError error: NSError?) {
        
        GIDSignIn.sharedInstance().delegate = nil
        
        if let error = error {
            GIDSignIn.sharedInstance().signOut()
            errorSubject.onNext(error)
            return
        }
        
        if let serverAuthCode = user?.serverAuthCode {
            let params = APIAuthService.googleLoginParamsWithToken(serverAuthCode)
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

