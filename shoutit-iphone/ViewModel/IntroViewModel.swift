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
import ShoutitKit

final class IntroViewModel {
    
    fileprivate let disposeBag = DisposeBag()
    let loginSuccessSubject = PublishSubject<Void>()
    let progressHUDSubject = PublishSubject<Bool>()
    let errorSubject = PublishSubject<Error>()
    
    func fetchGuestUser() {
        
        self.progressHUDSubject.onNext(true)
        let params = LoginGuestParams(apns: Account.sharedInstance.apnsToken as AnyObject?, mixPanelId: MixpanelHelper.getDistictId(), currentUserLocation: LocationManager.sharedInstance.currentLocation.coordinate)
        
        let observable: Observable<(AuthData, GuestUser)> = APIAuthService.getOAuthToken(params)
        observable
            .subscribe {[weak self] (event) in
                self?.progressHUDSubject.onNext(false)
                switch event {
                case .next((let authData, let user)):
                    try! Account.sharedInstance.loginUser(user, withAuthData: authData)
                    self?.loginSuccessSubject.onNext(())
                case .error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
}
