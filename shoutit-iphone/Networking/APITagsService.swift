//
//  APITagsService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 08.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import PureJsonSerializer

class APITagsService {
    
    private static let tagListenURL = APIManager.baseURL + "/tags/*/listen"
    private static let batchTagListenURL = APIManager.baseURL + "/tags/batch_listen"
    
    // MARK: - Traditional
    
    static func requestListenTagWithName(name: String, withCompletionHandler completionHandler: Result<Bool, NSError> -> Void) {
        
        let url = tagListenURL.stringByReplacingOccurrencesOfString("*", withString: name)
        
        APIManager.manager().request(.POST, url, parameters: nil, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success:
                completionHandler(.Success(true))
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    static func requestListenTagDeleteWithName(name: String, withCompletionHandler completionHandler: Result<Bool, NSError> -> Void) {
        
        let url = tagListenURL.stringByReplacingOccurrencesOfString("*", withString: name)
        
        APIManager.manager().request(.DELETE, url, parameters: nil, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success:
                completionHandler(.Success(true))
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    static func requestBatchListenTagWithParams(params: BatchListenParams, withCompletionHandler completionHandler: Result<Bool, NSError> -> Void) {
        
        APIManager.manager().request(.POST, batchTagListenURL, parameters: params.params, encoding: .JSON, headers: nil).validate(statusCode: 200..<300).responseData { (response) in
            switch response.result {
            case .Success:
                completionHandler(.Success(true))
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
        }
    }
    
    // MARK: - RX
    
    static func requestBatchListenTagWithParams(params: BatchListenParams) -> Observable<Result<Bool, NSError>> {
        
        return Observable.create { (observer) -> Disposable in
            self.requestBatchListenTagWithParams(params, withCompletionHandler: { (result) in
                observer.onNext(result)
            })
            return NopDisposable.instance
        }
    }
}
