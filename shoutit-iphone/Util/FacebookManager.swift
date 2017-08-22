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
import ShoutitKit

enum FacebookPermissions: String {
    case Email = "email"
    case PublicProfile = "public_profile"
    case UserBirthday = "user_birthday"
    case PublishActions = "publish_actions"
    case UserFriends = "user_friends"
    case ManagePages = "manage_pages"
    case PublishPages = "publish_pages"
    
    static var loginReadPermissions: [FacebookPermissions] {
        return [.Email, .PublicProfile]
    }
}

final class SHFBSDKLoginManager: FBSDKLoginManager {
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        // override method to disable implicit login cancellation
    }
}

class FacebookManager {
    
    fileprivate let account: Account
    fileprivate let loginManager: SHFBSDKLoginManager
    fileprivate let disposeBag = DisposeBag()
    
    init(account: Account) {
        self.account = account
        self.loginManager = SHFBSDKLoginManager()
    }
}

extension FacebookManager {
    
    func hasPermissions(_ permissions: FacebookPermissions) -> Bool {
        guard case .some(.logged(let user)) = account.loginState else { return false }
        guard let facebookAccount = user.linkedAccounts?.facebook else { return false }
        guard let currentAccessToken = FBSDKAccessToken.current() else { return false }
        return facebookAccount.scopes.contains(permissions.rawValue) && currentAccessToken.hasGranted(permissions.rawValue)
    }
    
    func checkExpiryDateWithProfile(_ profile: DetailedUserProfile) {
        guard let facebookAccount = profile.linkedAccounts?.facebook else { return }
        
        if Date().timeIntervalSince1970 >= TimeInterval(facebookAccount.expiresAtEpoch) {
            renewPermissions()
        }
    }
    
    func requestReadPermissionsFromViewController(_ permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            
            self.loginManager
                .logIn(withReadPermissions: permissions.map{$0.rawValue},
                from: viewController) { (result, error) -> Void in
                    
                    switch (result, error) {
                    case let (_, e?):
                        observer.onError(e)
                    case let (r?, _):
                        if result.isCancelled {
                            observer.onError(LocalError.cancelled)
                        } else {
                            observer.onNext(r.token.tokenString)
                            observer.onCompleted()
                        }
                    default:
                        assertionFailure()
                        observer.onError(LocalError.unknownError)
                    }
            }
            
            return NopDisposable.instance
        }
    }
    
    func linkWithReadPermissions(_ permissions: [FacebookPermissions] = FacebookPermissions.loginReadPermissions, viewController: UIViewController) -> Observable<Success> {
        return hasBasicReadPermissionsObservable()
            .flatMap{[unowned self] (hasReadPermissions) -> Observable<String> in
                if !hasReadPermissions {
                    return self.requestReadPermissionsFromViewController(FacebookPermissions.loginReadPermissions, viewController: viewController)
                }
                
                guard let currentAccessToken = FBSDKAccessToken.current(), let token = currentAccessToken.tokenString else {
                    return self.requestReadPermissionsFromViewController(FacebookPermissions.loginReadPermissions, viewController: viewController)
                }
                
                return Observable.just(token)
            
            }
            .flatMap{ (token) in
                return APIProfileService.linkSocialAccountWithParams(.facebook(token: token))
        }
    }

    func unlinkFacebookAccount() -> Observable<Success> {
        return APIProfileService.unlinkSocialAccountWithParams(.facebook(token: nil))
    }
    
    func requestPublishPermissions(_ permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<Success> {
        
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
            }
            .flatMap {[unowned self](_) -> Observable<String> in
                return self.facebookPublishPermssionsObservableWithViewController(permissions, viewController: viewController)
            }
            .flatMap{ (token) in
                return APIProfileService.linkSocialAccountWithParams(.facebook(token: token))
            }
    }
    
    func requestManagePermissions(_ permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<Void> {
        
        return self.facebookPublishPermssionsObservableWithViewController(permissions, viewController: viewController).flatMap{ (token) in
                return Observable.just(Void())
        }
    }
    
    func extendUserReadPermissions(_ permissions: [FacebookPermissions], viewController: UIViewController) -> Observable<Success> {
        return hasBasicReadPermissionsObservable()
            .flatMap{(hasBasicReadPermissions) -> Observable<[FacebookPermissions]> in
                if hasBasicReadPermissions {
                    return Observable.just(permissions)
                } else {
                    return Observable.just((permissions + FacebookPermissions.loginReadPermissions).unique())
                }
            }
            .flatMap {[unowned self](composedPermissions) -> Observable<String> in
                self.requestReadPermissionsFromViewController(composedPermissions, viewController: viewController)
            }
            .flatMap{ (token) in return APIProfileService.linkSocialAccountWithParams(.facebook(token: token))}
    }
    
    
    func logout() {
        loginManager.logOut()
    }
}

private extension FacebookManager {
    
    func facebookPublishPermssionsObservableWithViewController(_ permissions:[FacebookPermissions], viewController: UIViewController) -> Observable<String> {
        
        return Observable.create{[unowned self] (observer) -> Disposable in
            self.loginManager
                .logIn(withPublishPermissions: permissions.map({$0.rawValue}), from: viewController) { (result, error) in
                    
                    switch (result, error) {
                    case let (_, e?):
                        observer.onError(e)
                    case let (r?, _):
                        if result.isCancelled {
                            observer.onError(LocalError.cancelled)
                        } else {
                            observer.onNext(r.token.tokenString)
                            observer.onCompleted()
                        }
                    default:
                        assertionFailure()
                        observer.onError(LocalError.unknownError)
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
            guard let currentAccessToken = FBSDKAccessToken.current() else { return }
            APIProfileService
                .linkSocialAccountWithParams(.facebook(token: currentAccessToken.tokenString))
                .subscribe{(_) in }
                .addDisposableTo(self.disposeBag)
        }
    }
}
