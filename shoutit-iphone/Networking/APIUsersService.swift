//
//  APIUsersService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 18.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import RxCocoa

class APIUsersService {
    
    private static let usersHomeShoutsURL = APIManager.baseURL + "/users/me/home"
    
    static func homeShouts() -> Observable<[Shout]> {
        
        return Observable.create({ (observer) -> Disposable in
            
            APIManager.manager()
                .request(.GET, usersHomeShoutsURL, parameters:nil, encoding: .URL, headers: ["Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseData { (response) in
                    
                    switch response.result {
                    case .Success(let data):
                        do {
                            
                            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            
                            if let j = json, jr = j.objectForKey("results") {
                                print(jr)
                                if let results : Decoded<[Shout]> = decode(jr) {
                                    
                                    if let value = results.value {
                                        observer.on(.Next(value))
                                        observer.on(.Completed)
                                    }
                                    if let err = results.error {
                                        print(err)
                                    }
                                }
                            }
                            
                            
                        } catch let error as NSError {
                            print(error)
                            observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                        }
                    case .Failure(let error):
                        print(error)
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
            }
            
            return NopDisposable.instance
        })
    }
}