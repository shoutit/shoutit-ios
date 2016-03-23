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
    
    static func listShoutsWithParams(params: FilteredShoutsParams) -> Observable<[Shout]> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL, responseJsonPath: ["results"])
    }
    
    static func searchShoutsWithParams(params: FilteredShoutsParams) -> Observable<SearchShoutsResults> {
        return APIGenericService.requestWithMethod(.GET, url: shoutsURL, params: params, encoding: .URL)
    }
    
    static func listCategories() -> Observable<[Category]> {
        let url = APIManager.baseURL + "/shouts/categories"
        return APIGenericService.requestWithMethod(.GET, url: url, params: NopParams(), encoding: .URL)
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