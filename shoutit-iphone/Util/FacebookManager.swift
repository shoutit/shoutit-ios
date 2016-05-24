//
//  FacebookManager.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 24.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import FBSDKCoreKit
import FBSDKLoginKit

enum FacebookPermissions: String {
    case Email = "email"
    case PublicProfile = "public_profile"
    case UserBirthday = "user_birthday"
    case PublishActions = "publish_actions"
    
    static var loginReadPermissions: [FacebookPermissions] {
        return [.Email, .PublicProfile]
    }
}

class FacebookManager {
    
    private let account: Account
    private let loginManager: FBSDKLoginManager
    private let disposeBag = DisposeBag()
    
    init(account: Account) {
        self.account = account
        self.loginManager = FBSDKLoginManager()
    }
}

extension FacebookManager {
    
    func hasPublishPermissions() -> Bool {
        guard case .Some(.Logged(let user)) = account.userModel else { return false }
        guard let facebookAccount = user.linkedAccounts?.facebook else { return false }
        return facebookAccount.scopes.contains(FacebookPermissions.PublishActions.rawValue) && FBSDKAccessToken.currentAccessToken().hasGranted(FacebookPermissions.PublishActions.rawValue)
    }
    
    func checkExpiryDate() {
        guard case .Some(.Logged(let profile)) = account.userModel else { return }
        guard let facebookAccount = profile.linkedAccounts?.facebook else { return }
        let expiryDate = NSDate(timeIntervalSince1970: NSTimeInterval(facebookAccount.expiresAtEpoch))
        if NSDate().compare(expiryDate) == NSComparisonResult.OrderedAscending {
            renewPermissions()
        }
    }
    
    func requestReadPermissionsFromViewController(viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.loginManager
                .logInWithReadPermissions(FacebookPermissions.loginReadPermissions.map{$0.rawValue},
                fromViewController: viewController) { (result, error) -> Void in
                    
                    switch (result, error) {
                    case let (_, e?):
                        observer.onError(e)
                    case let (r?, _):
                        if result.isCancelled {
                            observer.onError(LocalError.Cancelled)
                        } else {
                            observer.onNext(r.token.tokenString)
                            observer.onCompleted()
                        }
                    default:
                        assertionFailure()
                        observer.onError(LocalError.UnknownError)
                    }
            }
            
            return NopDisposable.instance
        }
    }
    
    func requestPublishPermssionsFromViewController(viewController: UIViewController) -> Observable<DetailedProfile> {
        
        return facebookPublishPermssionsObservableWithViewController(viewController)
            .flatMap{ (token) in return APIProfileService.linkSocialAccountWithParams(.Facebook(token: token))}
            .flatMap{ (profile) -> Observable<DetailedProfile> in
                guard let facebook = profile.linkedAccounts?.facebook else {
                    return Observable.error(SocialActionError.FacebookPermissionsFailedError)
                }
                guard facebook.scopes.contains(FacebookPermissions.PublishActions.rawValue) else {
                    return Observable.error(SocialActionError.FacebookPermissionsFailedError)
                }
                return Observable.just(profile)
            }
    }
}

private extension FacebookManager {
    
    func facebookPublishPermssionsObservableWithViewController(viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            self.loginManager
                .logInWithPublishPermissions([FacebookPermissions.PublishActions.rawValue], fromViewController: viewController) { (result, error) in
                    
                    switch (result, error) {
                    case let (_, e?):
                        observer.onError(e)
                    case let (r?, _):
                        if result.isCancelled {
                            observer.onError(LocalError.Cancelled)
                        } else {
                            observer.onNext(r.token.tokenString)
                            observer.onCompleted()
                        }
                    default:
                        assertionFailure()
                        observer.onError(LocalError.UnknownError)
                    }
            }
            
            return NopDisposable.instance
        }
    }
    
    func renewPermissions() {
        FBSDKAccessToken.refreshCurrentAccessToken {[unowned self] (fbsdkgraphrequestconnection, result, error) in
            guard error == nil else {
                return
            }
            
            APIProfileService
                .linkSocialAccountWithParams(.Facebook(token: FBSDKAccessToken.currentAccessToken().tokenString))
                .subscribe{(event) in
                    guard case .Next(let profile) = event else { return }
                    guard case .Some(.Logged(_)) = self.account.userModel else { return }
                    self.account.updateUserWithModel(profile)
                }
                .addDisposableTo(self.disposeBag)
        }
    }
}
