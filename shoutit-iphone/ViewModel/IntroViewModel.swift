//
//  IntroViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

class IntroViewModel {
    
    let loginSuccessSubject = PublishSubject<Void>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<NSError>()
    
    func fetchGuestUser() {
        
        self.progressHUDSubject.onNext(true)
        let params = LoginGuestParams()
        
        APIAuthService.getOauthToken(params) { (result: Result<(AuthData, GuestUser), NSError>) -> Void in
            self.progressHUDSubject.onNext(false)
            switch result {
            case .Success((let authData, let user)):
                try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                self.loginSuccessSubject.onNext(())
            case .Failure(let error):
                self.errorSubject.onNext(error)
            }
        }
    }
}
