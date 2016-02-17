//
//  APIDiscoverService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import PureJsonSerializer
import RxSwift
import RxCocoa
import Freddy

class APIDiscoverService {
    private static let discoverURL = APIManager.baseURL + "/discover"
    
    static func discover(forCountry country: String?, page_size: Int = 5, page: Int = 1) -> Observable<[DiscoverItem]> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["country": (country ?? ""), "page": page, "page_size": page_size]
            
            APIManager.manager().request(.GET, discoverURL, parameters:params, encoding: .URL, headers: nil).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    do {
                        let json = try JSON(data: data)
                        let results = try json.array("results").map(DiscoverItem.init)
                        
                        observer.on(.Next(results))
                        observer.on(.Completed)
                        
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
                        let json = try JSON(data: data)
                        let results = try json.array("children").map(DiscoverItem.init)
                        
                        observer.on(.Next(results))
                        observer.on(.Completed)
                        
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