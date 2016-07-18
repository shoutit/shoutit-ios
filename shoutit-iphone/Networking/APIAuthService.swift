//
//  APIAuthService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Argo
import Alamofire
import RxSwift
import ShoutitKit

final class APIAuthService {
    
    private static let oauth2AccessTokenURL = APIManager.baseURL + "/oauth2/access_token"
    private static let authResetPasswordURL = APIManager.baseURL + "/auth/reset_password"
    
    static func resetPassword(params: ResetPasswordParams) -> Observable<Success> {
        return APIGenericService.requestWithMethod(.POST, url: authResetPasswordURL, params: params, encoding: .JSON)
    }
    
    static func getOAuthToken<T: User where T: Decodable, T == T.DecodedType>(params: AuthParams) -> Observable<(AuthData, T)> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(.POST, oauth2AccessTokenURL, parameters: params.params, encoding: .JSON)
            let cancel = AnonymousDisposable {
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
    
    static func verifyEmail(params: EmailParams) -> Observable<Success> {
        let url = APIManager.baseURL + "/auth/verify_email"
        return APIGenericService.requestWithMethod(.POST, url: url, params: params, encoding: .JSON)
    }
    
    static func changePasswordWithParams(params: ChangePasswordParams) -> Observable<Void> {
        let url = APIManager.baseURL + "/auth/change_password"
        return APIGenericService.basicRequestWithMethod(.POST, url: url, params: params, encoding: .JSON)
    }
}
