//
//  APIGenericService.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 26.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import RxSwift
import RxCocoa

class APIGenericService {
    
    static func requestWithMethod<P: Params, T: Decodable where T == T.DecodedType>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<T> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
                .validate(statusCode: 200..<300)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                switch response.result {
                case .Success(let originalJson):
                    
                    let json: AnyObject
                    if let paths = responseJsonPath {
                        var nestedJson: AnyObject? = originalJson
                        for path in paths {
                            if let nested = nestedJson as? [String : AnyObject] {
                                nestedJson = nested[path]
                            }
                        }
                        guard let j = nestedJson else {
                            assert(false)
                            observer.onError(ParseError.InvalidJson)
                            return
                        }
                        json = j
                    } else {
                        json = originalJson
                    }
                    let decoded: Decoded<T> = decode(json)
                    switch decoded {
                    case .Success(let object):
                        observer.onNext(object)
                        observer.onCompleted()
                    case .Failure(let decodeError):
                        observer.onError(decodeError)
                    }
                case .Failure(let error):
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
    
    // array version
    static func requestWithMethod<P: Params, T: Decodable where T == T.DecodedType>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<[T]> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
                .validate(statusCode: 200..<300)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                switch response.result {
                case .Success(let originalJson):
                    
                    let json: AnyObject
                    if let paths = responseJsonPath {
                        var nestedJson: AnyObject? = originalJson
                        for path in paths {
                            if let nested = nestedJson as? [String : AnyObject] {
                                nestedJson = nested[path]
                            }
                        }
                        guard let j = nestedJson else {
                            assert(false)
                            observer.onError(ParseError.InvalidJson)
                            return
                        }
                        json = j
                    } else {
                        json = originalJson
                    }
                    let decoded: Decoded<[T]> = decode(json)
                    switch decoded {
                    case .Success(let objects):
                        observer.onNext(objects)
                        observer.onCompleted()
                    case .Failure(let decodeError):
                        assert(false, decodeError.description)
                        observer.onError(decodeError)
                    }
                case .Failure(let error):
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
}
