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
import ShoutitKit

final class APIGenericService {
    
    static func basicRequestWithMethod<P: Params>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Observable<Void> {
        
        let observable : Observable<Void> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            
            request.responseData{ (response) in
                guard let responseData = response.data where responseData.length > 0 else {
                    observer.onNext()
                    observer.onCompleted()
                    return
                }
                do {
                    let dataObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers)
                    
                    print(dataObject)
                    
                    
                    let result : Result<AnyObject, NSError> = Result.Success(dataObject)
                    let resp : Response<AnyObject, NSError> = Response(request: response.request, response: response.response, data: responseData, result: result)
                    
                    _ = try validateResponseAndExtractJson(resp)
                    observer.onNext()
                    observer.onCompleted()
                    
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
        
        return refreshTokenObservable().flatMap { (_) -> Observable<Void> in
            return observable
        }
    }
    
    static func requestWithMethod<P: Params, T: Decodable where T == T.DecodedType>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<T> {
        
        let observable : Observable<T> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            debugPrint(request)
            
            request.responseJSON{ (response) in
                do {
                    let originalJson = try validateResponseAndExtractJson(response)
                    let json = try extractJsonFromJson(originalJson, withPathComponents: responseJsonPath)
                    print(json)
                    let object: T = try parseJson(json)
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }
            
            return cancel
        }
        
        return refreshTokenObservable().flatMap { (_) -> Observable<T> in
            return observable
        }
    }
    
    static func requestWithMethod<P: Params, T: Decodable where T == T.DecodedType>(
        method: Alamofire.Method,
        url: URLStringConvertible,
        params: P?,
        encoding: ParameterEncoding = .URL,
        responseJsonPath: [String]? = nil,
        headers: [String: String]? = nil) -> Observable<[T]> {
        
        let observable : Observable<[T]> = Observable.create {(observer) -> Disposable in
            
            let request = APIManager.manager()
                .request(method, url, parameters: params?.params, encoding: encoding, headers: headers)
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
//            debugPrint(request)
            
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
        
        return refreshTokenObservable().flatMap { (_) -> Observable<[T]> in
            return observable
        }
    }
    
    private static func refreshTokenObservable() -> Observable<Void> {
        guard let tokenExpires = APIManager.tokenExpiresAt else {
            return Observable.just(Void())
            
        }
        
        if tokenExpires < Int(NSDate().timeIntervalSince1970) {
            debugPrint("Refreshing Access Token")

            guard let refreshToken =  APIManager.authData?.refreshToken else {
                return Observable.just(Void())
            }
            
            let params = RefreshTokenParams(refreshToken: refreshToken)
            
            if case .Some(.Page(_,_)) = Account.sharedInstance.loginState {
                let observable: Observable<(AuthData, DetailedPageProfile)> = APIAuthService.refreshAuthToken(params)
                
                return observable.flatMap({ (authData, page) -> Observable<Void> in
                    
                    do {
                        try Account.sharedInstance.loginUser(page, withAuthData: authData)
                        return Observable.just(Void())
                    } catch let error {
                        return Observable.error(error)
                    }
                })
                
            } else if case .Some(.Logged(_)) = Account.sharedInstance.loginState {
                let observable: Observable<(AuthData, DetailedUserProfile)> = APIAuthService.refreshAuthToken(params)
                
                return observable.flatMap({ (authData, page) -> Observable<Void> in
                    
                    do {
                        try Account.sharedInstance.loginUser(page, withAuthData: authData)
                        return Observable.just(Void())
                    } catch let error {
                        return Observable.error(error)
                    }
                })
            } else {
                let observable: Observable<(AuthData, GuestUser)> = APIAuthService.refreshAuthToken(params)
                
                return observable.flatMap({ (authData, page) -> Observable<Void> in
                    
                    do {
                        try Account.sharedInstance.loginUser(page, withAuthData: authData)
                        return Observable.just(Void())
                    } catch let error {
                        return Observable.error(error)
                    }
                })
            }
                        
        }
        
        return Observable.just(Void())
    }
    
    
    
    // MARK: - Helpers
    
    static func validateResponseAndExtractJson(response: Response<AnyObject, NSError>) throws -> AnyObject {
        
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
    
    static func extractJsonFromJson(json: AnyObject, withPathComponents components: [String]?) throws -> AnyObject {
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
            print(json)
            assertionFailure(InternalParseError.InvalidJson.userMessage)
            throw InternalParseError.InvalidJson
        }
        
        return j
    }
    
    static func parseJson<T: Decodable where T == T.DecodedType>(json: AnyObject, failureExpected: Bool = false) throws -> T {
        let decoded: Decoded<T> = decode(json)
        switch decoded {
        case .Success(let object):
            return object
        case .Failure(let decodeError):
            if !failureExpected {
                debugPrint(json)
                assertionFailure("\(decodeError.description) in model of type \(T.self)")
            }
            throw decodeError
        }
    }
    
    static func parseJsonArray<T: Decodable where T == T.DecodedType>(json: AnyObject) throws -> [T] {
        let decoded: Decoded<[T]> = decode(json)
        switch decoded {
        case .Success(let object):
            return object
        case .Failure(let decodeError):
            print(json)
            assertionFailure("\(decodeError.description) in model of type \(T.self)")
            throw decodeError
        }
    }
}
