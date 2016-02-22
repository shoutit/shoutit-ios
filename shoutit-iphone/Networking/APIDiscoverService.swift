//
//  APIDiscoverService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import Argo

class APIDiscoverService {
    private static let discoverURL = APIManager.baseURL + "/discover"
    
    static func discover(forCountry country: String?, page_size: Int = 5, page: Int = 1) -> Observable<[DiscoverItem]> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["country": (country ?? ""), "page": page, "page_size": page_size]
            
            APIManager.manager().request(.GET, discoverURL, parameters:params, encoding: .URL, headers: nil).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    do {
                        
                        let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        
                        if let j = json, jr = j.objectForKey("results") {
                            if let results : Decoded<[DiscoverItem]> = decode(jr) {
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
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
                case .Failure(let error):
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                }
            }
            
            return AnonymousDisposable {
            }
        })
    }
    
    static func shouts(forDiscoverItem discoverItem: DiscoverItem?) -> Observable<[DiscoverItem]> {
        return Observable.create({ (observer) -> Disposable in
            
            guard let discover = discoverItem else {
                observer.on(.Next([]))
                return AnonymousDisposable {}
            }
            
            APIManager.manager().request(.GET, discover.apiUrl, encoding: .URL, headers: nil).responseData({ (response) -> Void in

                switch response.result {
                case .Success(let data):
                    do {
                        let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        
                        if let j = json, jr = j.objectForKey("children") {
                            if let results : Decoded<[DiscoverItem]> = decode(jr) {
                                if let value = results.value {
                                    observer.on(.Next(value))
                                    observer.on(.Completed)
                                    return
                                }
                                if let err = results.error {
                                    observer.on(.Error(err))
                                }
                            }
                        }
                        
                    } catch let error as NSError {
                        observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    }
                case .Failure(let error):
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                }
            })
            
            return AnonymousDisposable {
            }
        })
    }
    
}