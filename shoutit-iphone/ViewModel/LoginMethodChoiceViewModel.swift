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

final class LoginMethodChoiceViewModel {
    
    //let googleLoginSubject = BehaviorSubject
    
    init() {
        
    }
    
    func loginWithGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}

extension LoginMethodChoiceViewModel: GIDSignInDelegate {
    
    @objc func signIn(signIn: GIDSignIn?, didSignInForUser user: GIDGoogleUser?, withError error: NSError?) {
        
            GIDSignIn.sharedInstance().delegate = nil
        
            if error == nil, let serverAuthCode = user?.serverAuthCode {
                let params = APIAuthService.googleLoginParamsWithToken(serverAuthCode)
                self.getOauthResponse(params)
            } else {
                GIDSignIn.sharedInstance().signOut()
                log.debug("\(error?.localizedDescription)")
            }
    }
    
    @objc func signIn(signIn: GIDSignIn?, didDisconnectWithUser user:GIDGoogleUser?,
        withError error: NSError?) {
            GIDSignIn.sharedInstance().delegate = nil
            log.verbose("Error getting Google Plus User")
    }
}

