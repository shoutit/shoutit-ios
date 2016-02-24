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

class APIAuthService {
    
    private static let oauth2AccessTokenURL = APIManager.baseURL + "/oauth2/access_token"
    private static let authResetPasswordURL = APIManager.baseURL + "/auth/reset_password"
    
    static func resetPassword(params: ResetPasswordParams, completionHandler: Result<Success, NSError> -> Void) {
        
        APIManager.manager()
            .request(.POST, authResetPasswordURL, parameters: params.params, encoding: .JSON, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                switch response.result {
                case .Success(let json):
                    do {
                        if let s: Decoded<Success> = decode(json), let success = s.value {
                            completionHandler(.Success(success))
                        } else {
                            throw ParseError.Success
                        }
                    } catch let error as NSError {
                        completionHandler(.Failure(error))
                    }
                case .Failure(let error):
                    completionHandler(.Failure(error))
                }
        }
    }
    
    static func getOauthToken(params: AuthParams, completionHandler: Result<(AuthData, User), NSError> -> Void) {
        
        APIManager.manager()
            .request(.POST, oauth2AccessTokenURL, parameters: params.params, encoding: .JSON, headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                    do {
                        var auth: AuthData?
                        var user: User?
                        
                        if let decoded: Decoded<AuthData> = decode(json), let authData = decoded.value {
                            auth = authData
                        }
                        
                        if let userJson = json["user"] as? [String : AnyObject] {
                            user = SecureCoder.userWithDictionary(userJson)
                        }
                        
                        if let user = user, let auth = auth {
                            completionHandler(.Success(auth, user))
                        } else {
                            throw ParseError.AuthData
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
