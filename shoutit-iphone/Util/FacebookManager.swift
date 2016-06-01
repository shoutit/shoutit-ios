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
    case UserFriends = "user_friends"
    
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
    
    func hasPermissions(permissions: FacebookPermissions) -> Bool {
        guard case .Some(.Logged(let user)) = account.userModel else { return false }
        guard let facebookAccount = user.linkedAccounts?.facebook else { return false }
        return facebookAccount.scopes.contains(permissions.rawValue) && FBSDKAccessToken.currentAccessToken().hasGranted(permissions.rawValue)
    }
    
    func checkExpiryDateWithProfile(profile: DetailedProfile) {
        guard let facebookAccount = profile.linkedAccounts?.facebook else { return }
        let expiryDate = NSDate(timeIntervalSince1970: NSTimeInterval(facebookAccount.expiresAtEpoch))
        if NSDate().compare(expiryDate) == NSComparisonResult.OrderedAscending {
            renewPermissions()
        }
    }
    
    func requestReadPermissionsFromViewController(permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.loginManager
                .logInWithReadPermissions(permissions.map{$0.rawValue},
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
    
    func requestPublishPermissions(permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<Void> {
        
        return hasBasicReadPermissionsObservable()
            .flatMap{[unowned self] (hasReadPermissions) -> Observable<Void> in
                if hasReadPermissions {
                    return Observable.just()
                } else {
                    return self.requestReadPermissionsFromViewController(FacebookPermissions.loginReadPermissions, viewController: viewController)
                        .map{ (_) -> Void in
                            return Void()
                    }
                }
            }.flatMap {[unowned self](_) -> Observable<String> in
                return self.facebookPublishPermssionsObservableWithViewController(permissions, viewController: viewController)
            }
            .flatMap{ (token) in return APIProfileService.linkSocialAccountWithParams(.Facebook(token: token))}
    }
    
    func extendUserReadPermissions(permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<Void> {
        return hasBasicReadPermissionsObservable()
            .flatMap{(hasBasicReadPermissions) -> Observable<[FacebookPermissions]> in
                if hasBasicReadPermissions {
                    return Observable.just(permissions)
                } else {
                    return Observable.just((permissions + FacebookPermissions.loginReadPermissions).unique())
                }
            }
            .flatMap {[unowned self](composedPermissions) -> Observable<String> in
                self.requestReadPermissionsFromViewController(permissions, viewController: viewController)
            }
            .flatMap{ (token) in return APIProfileService.linkSocialAccountWithParams(.Facebook(token: token))}
    }
    
    func logout() {
        loginManager.logOut()
    }
}

private extension FacebookManager {
    
    func facebookPublishPermssionsObservableWithViewController(permissions:[FacebookPermissions], viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            self.loginManager
                .logInWithPublishPermissions(permissions.map({$0.rawValue}), fromViewController: viewController) { (result, error) in
                    
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
    
    func hasBasicReadPermissionsObservable() -> Observable<Bool> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            observer.onNext(self.hasPermissions(.Email) && self.hasPermissions(.PublicProfile))
            observer.onCompleted()
            return NopDisposable.instance
        }
    }
    
    func renewPermissions() {
        
        FBSDKAccessToken.refreshCurrentAccessToken {[unowned self] (fbsdkgraphrequestconnection, result, error) in
            guard error == nil else { return }
            APIProfileService
                .linkSocialAccountWithParams(.Facebook(token: FBSDKAccessToken.currentAccessToken().tokenString))
                .subscribe{(_) in }
                .addDisposableTo(self.disposeBag)
        }
    }
}
