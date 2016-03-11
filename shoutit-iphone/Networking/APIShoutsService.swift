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
            let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
            let params: [String: AnyObject] = ["country": (country ?? countryCode) as NSString, "page": page as NSNumber, "page_size": page_size as NSNumber]

            APIManager.manager()
                .request(.GET, shoutsURL, parameters:params, encoding: .URL, headers: ["Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseData { (response) in
                    
                    switch response.result {
                    case .Success(let data):
                        do {
                            
                            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            
                            if let j = json, jr = j.objectForKey("results") {
                                if let results : Decoded<[Shout]> = decode(jr) {
                                    
                                    if let value = results.value {
                                        observer.on(.Next(value))
                                        observer.on(.Completed)
                                        return
                                    }
                                    if let err = results.error {
                                        print(err)
                                        observer.on(.Next([]))
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
            
            let request = APIManager.manager().request(.GET, shoutsURL + "?discover=\(discoverItem.id)", parameters:params, encoding: .URL, headers: ["Accept": "application/json"]).validate(statusCode: 200..<300).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    do {
                        
                        let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        
                        if let j = json, jr = j.objectForKey("results") {
                            if let results : Decoded<[Shout]> = decode(jr) {
                                print(jr)
                                
                                if let value = results.value {
                                    observer.on(.Next(value))
                                }
                                if let err = results.error {
                                    observer.on(.Error(err ?? RxCocoaURLError.Unknown))
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
            
            debugPrint(request)
            
            return AnonymousDisposable {
            }
            
            
        })
        
    }
    
    static func shoutsForUserWithParams(params: UserShoutsParams) -> Observable<[Shout]> {
        return APIGenericService.requestWithMethod(.GET,
                                                   url: shoutsURL,
                                                   params: params,
                                                   encoding: .URL,
                                                   responseJsonPath: ["results"])
    }
    
    static func retrieveShoutWithId(id: String) -> Observable<Shout> {
        let url = shoutsURL + "/\(id)"
        return APIGenericService.requestWithMethod(.GET,
                                                   url: url,
                                                   params: NopParams())
    }
    
    static func relatedShoutsWithParams(params: RelatedShoutsParams) -> Observable<[Shout]> {
        let url = shoutsURL + "/\(params.shout.id)/related"
        return APIGenericService.requestWithMethod(.GET, url: url,
                                                   params: params,
                                                   encoding: .URL,
                                                   responseJsonPath: ["results"],
                                                   headers: ["Accept": "application/json"])
    }


    static func createShoutWithParams(params: [String : AnyObject]) -> Observable<Shout> {
        
        return Observable.create{ (observer) -> Disposable in
            
            APIManager.manager()
                .request(.POST, shoutsURL, parameters: params, encoding: .JSON, headers: ["Accept": "application/json"])
                .validate(statusCode: 200..<401)
                .responseData({ (response) in
                    
                    switch response.result {
                    case .Success(let data):
                        
                        do {
                            
                            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            
                            if let j = json {
                                if let results : Decoded<Shout> = decode(j) {
                                    print(json)
                                    if let value = results.value {
                                        observer.on(.Next(value))
                                        observer.on(.Completed)
                                    }
                                    if let err = results.error {
                                        print(err)
                                        print(json)
                                        
                                        observer.on(.Error(err ?? RxCocoaURLError.Unknown))
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
    
    static func updateShoutWithParams(params: [String : AnyObject], uid: String) -> Observable<Shout> {
        
        return Observable.create{ (observer) -> Disposable in
            
            APIManager.manager()
                .request(.PATCH, shoutsURL + "/\(uid)", parameters: params, encoding: .JSON, headers: ["Accept": "application/json"])
                .validate(statusCode: 200..<401)
                .responseData({ (response) in
                    
                    switch response.result {
                    case .Success(let data):
                        
                        do {
                            
                            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                            
                            if let j = json {
                                if let results : Decoded<Shout> = decode(j) {
                                    
                                    if let value = results.value {
                                        observer.on(.Next(value))
                                        observer.on(.Completed)
                                    }
                                    if let err = results.error {
                                        observer.on(.Error(err ?? RxCocoaURLError.Unknown))
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
}