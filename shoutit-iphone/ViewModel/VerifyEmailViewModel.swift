//
//  VerifyEmailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift

class VerifyEmailViewModel {
    
    private(set) var profile: DetailedProfile
    
    var email: Variable<String>
    
    init(profile: DetailedProfile) {
        self.profile = profile
        self.email = Variable(profile.email ?? "")
    }
    
    // RX
    let successSubject: PublishSubject<String> = PublishSubject()
    let errorSubject: PublishSubject<ErrorType> = PublishSubject()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    private let disposeBag = DisposeBag()
    
    func verifyEmail() {
        progressSubject.onNext(true)
        verifyEmailObservable()
            .subscribe {[weak self] (event) in
                self?.progressSubject.onNext(false)
                switch event {
                case .Next((let success, let detailedProfile)):
                    self?.profile = detailedProfile
                    Account.sharedInstance.loggedUser = detailedProfile
                    self?.successSubject.onNext(success.message)
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func updateUser() {
        progressSubject.onNext(true)
        updateUserObservable()
            .subscribe {[weak self] (event) in
                self?.progressSubject.onNext(false)
                switch event {
                case .Next(let detailedProfile):
                    self?.profile = detailedProfile
                    Account.sharedInstance.loggedUser = detailedProfile
                    if detailedProfile.isActivated {
                        let message = NSLocalizedString("Your account has been successfully verified", comment: "Verify email user message")
                        self?.successSubject.onNext(message)
                    } else {
                        let message = NSLocalizedString("Your account isn't verified yet", comment: "Verify email failed user message")
                        let error = LightError(userMessage: message)
                        self?.errorSubject.onNext(error)
                    }
                case .Error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Helpers
    
    func verifyEmailObservable() -> Observable<(Success, DetailedProfile)> {
        let emailParam: String? = email.value == profile.email ? nil : email.value
        let params = EmailParams(email: emailParam)
        return APIAuthService
            .verifyEmail(params)
            .flatMap{[unowned self] (success) -> Observable<(Success, DetailedProfile)> in
                return APIProfileService
                    .retrieveProfileWithUsername(self.profile.username)
                    .map{ (detailedProfile) -> (Success, DetailedProfile) in
                        return (success, detailedProfile)
                }
        }
    }
    
    func updateUserObservable() -> Observable<DetailedProfile> {
        return APIProfileService.retrieveProfileWithUsername(profile.username)
    }
}