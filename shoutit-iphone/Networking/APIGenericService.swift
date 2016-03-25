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
    
    static func basicRequestWithMethod<P: Params>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Observable<Void> {
        
        return Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    _ = try validateResponseAndExtractJson(response)
                    observer.onNext()
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
    
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
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    let object: T = try parseJson(json)
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
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
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    let object: [T] = try parseJsonArray(json)
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
    }
    
    // MARK: - Private
    
    private static func validateResponseAndExtractJson(response: Response<AnyObject, NSError>) throws -> AnyObject {
        
        switch response.result {
        case .Success(let originalJson):
            if let httpResponse = response.response where (200..<300) ~= httpResponse.statusCode {
                return originalJson
            }
            
            guard let json = originalJson as? [String : AnyObject], let errorJson = json["error"] else {
                assertionFailure()
                throw InternalParseError.InvalidJson
            }
            
            let decoded: Decoded<APIError> = decode(errorJson)
            switch decoded {
            case .Success(let error):
                throw error
            case .Failure(let decodeError):
                assertionFailure(decodeError.description)
                throw decodeError
            }
            
        case .Failure(let error):
            throw error
        }
    }
    
    private static func extractJsonFromJson(json: AnyObject, withPathComponents components: [String]?) throws -> AnyObject {
        guard let components = components else {
            return json
        }
        
        var nestedJson: AnyObject? = json
        for path in components {
            if let nested = nestedJson as? [String : AnyObject] {
                nestedJson = nested[path]
            }
        }
        guard let j = nestedJson else {
            assertionFailure(InternalParseError.InvalidJson.userMessage)
            throw InternalParseError.InvalidJson
        }
        
        return j
    }
    
    private static func parseJson<T: Decodable where T == T.DecodedType>(json: AnyObject) throws -> T {
        let decoded: Decoded<T> = decode(json)
        switch decoded {
        case .Success(let object):
            return object
        case .Failure(let decodeError):
            assertionFailure(decodeError.description)
            throw decodeError
        }
    }
    
    private static func parseJsonArray<T: Decodable where T == T.DecodedType>(json: AnyObject) throws -> [T] {
        let decoded: Decoded<[T]> = decode(json)
        switch decoded {
        case .Success(let object):
            return object
        case .Failure(let decodeError):
            assertionFailure(decodeError.description)
            throw decodeError
        }
    }
}
