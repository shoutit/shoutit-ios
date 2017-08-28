//
//  APIAuthService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import ShoutitKit

final class APIAuthService {
    
    fileprivate static let oauth2AccessTokenURL = APIManager.baseURL + "/oauth2/access_token"
    fileprivate static let authResetPasswordURL = APIManager.baseURL + "/auth/reset_password"
    
    static func resetPassword(_ params: ResetPasswordParams) -> Observable<Success> {
        return APIGenericService.requestWithMethod(.post, url: authResetPasswordURL, params: params, encoding: JSONEncoding.default)
    }
    
    static func getOAuthToken<T: User>(_ params: AuthParams) -> Observable<(AuthData, T)> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(.post, oauth2AccessTokenURL, parameters: params.params, encoding: JSONEncoding.default)
            let cancel = Disposables.create {
                request.cancel()
            }
            
            debugPrint(request)
            
            request.responseJSON{ (response) in
                do {
                    let json = try APIGenericService.validateResponseAndExtractJson(response)
                    let userJson = try APIGenericService.extractJsonFromJson(json, withPathComponents: ["profile"])
                    let authData: AuthData = try APIGenericService.parseJson(json)
                    let user: T = try APIGenericService.parseJson(userJson)
                    observer.onNext((authData, user))
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
    
    static func refreshAuthToken(_ params: RefreshTokenParams) -> Observable<AuthData> {
        
        return Observable.create({ (observer) -> Disposable in
            let request = APIManager.manager()
                .request(.post, oauth2AccessTokenURL, parameters: params.params, encoding: JSONEncoding.default)
            let cancel = Disposables.create {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let json = try APIGenericService.validateResponseAndExtractJson(response)
                    let authData: AuthData = try APIGenericService.parseJson(json)
                    observer.onNext(authData)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        })
    }
    
    static func verifyEmail(_ params: EmailParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/auth/verify_email"
        return APIGenericService.requestWithMethod(.post, url: url, params: params, encoding: JSONEncoding.default)
    }
    
    static func changePasswordWithParams(_ params: ChangePasswordParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/auth/change_password"
        return APIGenericService.requestWithMethod(.post, url: url, params: params, encoding: JSONEncoding.default)
    }
}
