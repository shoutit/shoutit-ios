//
//  IntroViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 22.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class IntroViewModel {
    
    let loginSuccessSubject = PublishSubject<Void>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<NSError>()
    
    func fetchGuestUser() {
        
        let params = LoginGuestParams()
        
        APIAuthService.getOauthToken(params) { (result) -> Void in
            self.progressHUDSubject.onNext(false)
            switch result {
            case .Success(let authData):
                try! Account.sharedInstance.loginUserWithAuthData(authData)
                self.loginSuccessSubject.onNext(())
            case .Failure(let error):
                self.errorSubject.onNext(error)
            }
        }
    }
}
