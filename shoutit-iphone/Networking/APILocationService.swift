
//
//  APILocationService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 11/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Alamofire
import RxSwift
import ShoutitKit

final class APILocationService {
    fileprivate static let usersURL = APIManager.baseURL + "/profiles/*"
    
    static func updateLocationForUser(_ username: String, withParams params: CoordinateParams) -> Observable<User> {
        let url = usersURL.replacingOccurrences(of: "*", with: username)
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(.PATCH, url, parameters: params.params, encoding: .json)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let json = try APIGenericService.validateResponseAndExtractJson(response)
                    if let loggedUser: DetailedUserProfile = try? APIGenericService.parseJson(json, failureExpected: true) {
                        Account.sharedInstance.updateUserWithModel(loggedUser)
                        observer.onNext(loggedUser)
                    } else if let guestUser: GuestUser = try? APIGenericService.parseJson(json, failureExpected: true) {
                        Account.sharedInstance.updateUserWithModel(guestUser)
                        observer.onNext(guestUser)
                    } else {
                        throw InternalParseError.invalidJson
                    }
                    
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
    
    static func updateLocationForPage(_ username: String, withParams params: CoordinateParams) -> Observable<User> {
        let url = usersURL.replacingOccurrences(of: "*", with: username)
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(.PATCH, url, parameters: params.params, encoding: .json)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let json = try APIGenericService.validateResponseAndExtractJson(response)
                    if let loggedUser: DetailedPageProfile = try? APIGenericService.parseJson(json, failureExpected: true) {
                        Account.sharedInstance.updateUserWithModel(loggedUser)
                        observer.onNext(loggedUser)
                    } else if let guestUser: GuestUser = try? APIGenericService.parseJson(json, failureExpected: true) {
                        Account.sharedInstance.updateUserWithModel(guestUser)
                        observer.onNext(guestUser)
                    } else {
                        throw InternalParseError.invalidJson
                    }
                    
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
}
