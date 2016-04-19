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

final class IntroViewModel {
    
    private let disposeBag = DisposeBag()
    let loginSuccessSubject = PublishSubject<Void>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<ErrorType>()
    
    func fetchGuestUser() {
        
        self.progressHUDSubject.onNext(true)
        let params = LoginGuestParams()
        
        let observable: Observable<(AuthData, GuestUser)> = APIAuthService.getOAuthToken(params)
        observable
            .subscribe {[weak self] (event) in
                self?.progressHUDSubject.onNext(false)
                switch event {
                case .Next((let authData, let user)):
                    try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                    self?.loginSuccessSubject.onNext(())
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
