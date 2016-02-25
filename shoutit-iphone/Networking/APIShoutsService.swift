//
//  APIShoutsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import RxCocoa

class APIShoutsService {
    
    private static let shoutsURL = APIManager.baseURL + "/shouts"
    
    static func shouts(forCountry country: String?, page_size: Int = 20, page: Int = 1) -> Observable<[Shout]> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["country": (country ?? "") as NSString, "page": page as NSNumber, "page_size": page_size as NSNumber]

            APIManager.manager()
                .request(.GET, shoutsURL, parameters:params, encoding: .URL, headers: ["Accept": "application/json"])
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
            
            return AnonymousDisposable {
            }
        })
    }
    
    static func shouts(forDiscoverItem discoverItem: DiscoverItem, page_size: Int = 20, page: Int = 1) -> Observable<[Shout]> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["page": page, "page_size": page_size]
            
            APIManager.manager().request(.GET, shoutsURL + "?discover=\(discoverItem.id)", parameters:params, encoding: .URL, headers: ["Accept": "application/json"]).validate(statusCode: 200..<300).responseData { (response) in
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
            
            return AnonymousDisposable {
            }
        })
    }

    static func shoutsForUserWithParams(params: UserShoutsParams) -> Observable<[Shout]> {
        
        return Observable.create{ (observer) -> Disposable in
            
            APIManager.manager()
                .request(.GET, shoutsURL, parameters: params.params, encoding: .URL, headers: ["Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseData({ (response) in
                    
                    switch response.result {
                    case .Success(let data):
                        
                        do {
                            
                            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            
                            if let j = json, jr = j.objectForKey("results") {
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
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
                })
            
            return NopDisposable.instance
        }
    }
    
    static func retrieveShoutWithId(id: String) -> Observable<Shout> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager().request(.GET, <#T##URLString: URLStringConvertible##URLStringConvertible#>, parameters: <#T##[String : AnyObject]?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##[String : String]?#>)
            
            let cancel = AnonymousDisposable {
                
            }
            
            return NopDisposable.instance
        }
    }
}