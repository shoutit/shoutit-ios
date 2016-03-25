
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

class APILocationService {
    private static let usersURL = APIManager.baseURL + "/users/*"
    
    static func updateLocationForUser(username: String, withParams params: CoordinateParams) -> Observable<User> {
        let url = usersURL.stringByReplacingOccurrencesOfString("*", withString: username)
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(.PATCH, url, parameters: params.params, encoding: .JSON)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let json = try APIGenericService.validateResponseAndExtractJson(response)
                    let loggedUser: LoggedUser? = try? APIGenericService.parseJson(json)
                    let guestUser: GuestUser? = try? APIGenericService.parseJson(json)
                    
                    guard (guestUser != nil || loggedUser != nil) && (guestUser == nil || loggedUser == nil) else {
                        throw InternalParseError.InvalidJson
                    }
                    
                    Account.sharedInstance.guestUser = guestUser
                    Account.sharedInstance.loggedUser = loggedUser
                    
                    observer.onNext(guestUser ?? loggedUser!)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
}
