//
//  APIShoutsService.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Freddy
import RxSwift
import RxCocoa

class APIShoutsService {
    private static let shoutsURL = APIManager.baseURL + "/shouts"
    
    static func shouts(forCountry country: String?, page_size: Int = 25, page: Int = 1) -> Observable<[Shout]> {
        return Observable.create({ (observer) -> Disposable in
            
            let params: [String: AnyObject] = ["country": (country ?? ""), "page": page, "page_size": page_size]
            
            APIManager.manager().request(.GET, shoutsURL, parameters:params, encoding: .JSON).validate(statusCode: 200..<300).responseData { (response) in
                switch response.result {
                case .Success(let data):
                    do {
                        let json = try JSON(data: data)
                        let results = try json.array("results").map(Shout.init)
                        
                        observer.on(.Next(results))
                        observer.on(.Completed)
                        
                    } catch let error as NSError {
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
}