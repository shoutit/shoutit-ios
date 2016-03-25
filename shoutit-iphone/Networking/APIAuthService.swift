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

class APIAuthService {
    
    private static let oauth2AccessTokenURL = APIManager.baseURL + "/oauth2/access_token"
    private static let authResetPasswordURL = APIManager.baseURL + "/auth/reset_password"
    
    static func resetPassword(params: ResetPasswordParams) -> Observable<Success> {
        return APIGenericService.requestWithMethod(.POST, url: authResetPasswordURL, params: params, encoding: .JSON)
    }
    
    static func getOauthToken<T: User where T: Decodable, T == T.DecodedType>(params: AuthParams, completionHandler: Result<(AuthData, T), NSError> -> Void) {
        
        APIManager.manager()
            .request(.POST, oauth2AccessTokenURL, parameters: params.params, encoding: .JSON, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                    do {
                        var auth: AuthData?
                        
                        let decoded: Decoded<AuthData> = decode(json)
                        switch decoded {
                        case .Success(let authData):
                            auth = authData
                        case .Failure(let error):
                            throw error
                        }
                        
                        if let userJson = json["user"] as? [String : AnyObject] {
                            
                            let docoded: Decoded<T> = decode(userJson)
                            let user: T? = docoded.value
                            
                            if let user = user as? LoggedUser {
                                Account.sharedInstance.loggedUser = user
                            } else if let user = user as? GuestUser {
                                Account.sharedInstance.guestUser = user
                            }
                            
                            if let user = user, let auth = auth {
                                completionHandler(.Success(auth, user))
                            } else {
                                throw InternalParseError.User
                            }
                        }

                    } catch let error as NSError {
                        completionHandler(.Failure(error))
                    }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
}
