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

class APIDiscoverService {
    private static let discoverURL = APIManager.baseURL + "/discover"
    
    static func discover(forCountry country: String, page_size: Int = 5, page: Int = 0) -> Observable<([DiscoverItem])> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["country": country, "page": page, "page_size": page_size]
            
            APIManager.manager().request(.GET, discoverURL, parameters:params, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    do {
                        let json = try Json.deserialize(data)

                        let results = try [DiscoverItem](js: json)
                        
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
    
}