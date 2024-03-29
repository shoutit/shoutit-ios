//
//  VerifyEmailViewModel.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 29.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class VerifyEmailViewModel {
    
    fileprivate(set) var profile: DetailedUserProfile
    
    var email: Variable<String>
    
    init(profile: DetailedUserProfile) {
        self.profile = profile
        self.email = Variable(profile.email ?? "")
    }
    
    // RX
    let successSubject: PublishSubject<String> = PublishSubject()
    let errorSubject: PublishSubject<Error> = PublishSubject()
    let progressSubject: PublishSubject<Bool> = PublishSubject()
    fileprivate let disposeBag = DisposeBag()
    
    func verifyEmail() {
        progressSubject.onNext(true)
        verifyEmailObservable()
            .subscribe {[weak self] (event) in
                self?.progressSubject.onNext(false)
                switch event {
                case .next((let success, let detailedProfile)):
                    self?.profile = detailedProfile
                    Account.sharedInstance.updateUserWithModel(detailedProfile)
                    self?.successSubject.onNext(success.message)
                case .error(let error):
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
                case .next(let detailedProfile):
                    self?.profile = detailedProfile
                    Account.sharedInstance.updateUserWithModel(detailedProfile)
                    if detailedProfile.isActivated {
                        let message = NSLocalizedString("Your account has been successfully verified", comment: "Verify email user message")
                        self?.successSubject.onNext(message)
                    } else {
                        let message = NSLocalizedString("Your account isn't verified yet", comment: "Verify email failed user message")
                        let error = LightError(userMessage: message)
                        self?.errorSubject.onNext(error)
                    }
                case .error(let error):
                    self?.errorSubject.onNext(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Helpers
    
    func verifyEmailObservable() -> Observable<(Success, DetailedUserProfile)> {
        let emailParam: String? = email.value == profile.email ? nil : email.value
        let params = EmailParams(email: emailParam)
        return APIAuthService
            .verifyEmail(params)
            .flatMap{[unowned self] (success) -> Observable<(Success, DetailedUserProfile)> in
                return APIProfileService
                    .retrieveProfileWithUsername(self.profile.username)
                    .map{ (detailedProfile) -> (Success, DetailedUserProfile) in
                        return (success, detailedProfile)
                }
        }
    }
    
    func updateUserObservable() -> Observable<DetailedUserProfile> {
        return APIProfileService.retrieveProfileWithUsername(profile.username)
    }
}
