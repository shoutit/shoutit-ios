//
//  APIAuthService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 28.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import Alamofire

class APIAuthService {
    
    private static let oauth2AccessTokenURL = APIManager.baseURL + "/oauth2/access_token"
    private static let authResetPasswordURL = APIManager.baseURL + "/auth/reset_password"
    
    // MARK: - Actions
    
    static func resetPassword(params: ResetPasswordParams, completionHandler: Result<Success, NSError> -> Void) {
        
        APIManager.manager.request(.POST, authResetPasswordURL, parameters: params.params, encoding: .JSON, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                do {
                    let success = try Success(js: json)
                    completionHandler(.Success(success))
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    static func getOauthToken(params: AuthParams, completionHandler: Result<AuthData, NSError> -> Void) {
        
        APIManager.manager.request(.POST, oauth2AccessTokenURL, parameters: params.params, encoding: .JSON, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let json):
                    do {
                        let authResponse = try AuthData(js: json)
                        completionHandler(.Success(authResponse))
                    } catch let error as NSError {
                        completionHandler(.Failure(error))
                    }
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
}
