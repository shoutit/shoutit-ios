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
    
    static var isRefreshingToken : Bool = false
    static var refreshTokenSubject : PublishSubject<Bool> = PublishSubject()
    static var refreshTokenObservableStore : Observable<Void>?
    static let disposeBag = DisposeBag()
    
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
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<Void> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<Void> in
                return observable
            })
        }
        
        
        return observable
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
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<T> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<T> in
                return observable
            })
        }
        
        
        return observable
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
        
        if isRefreshingToken {
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<[T]> in
                return observable
            })
        }
        
        if isTokenValid() == false {
            startRefreshingToken()
            return self.refreshTokenSubject.asObservable().take(1).filter{$0 == true}.flatMap({ (bool) -> Observable<[T]> in
                return observable
            })
        }
        
        
        return observable
    }
    
    
    static func isTokenValid() -> Bool {
        guard let tokenExpires = APIManager.tokenExpiresAt else {
            return true
            
        }
        
        return tokenExpires < Int(NSDate().timeIntervalSince1970)
    }
    
    static func startRefreshingToken() {
        isRefreshingToken = true
        
        guard let refreshToken =  APIManager.authData?.refreshToken else {
            self.refreshTokenSubject.onNext(true)
            return
        }
        
        
        let params = RefreshTokenParams(refreshToken: refreshToken)
        
        let observable: Observable<AuthData> = APIAuthService.refreshAuthToken(params)
        
        refreshTokenObservableStore = observable.flatMap({ authData -> Observable<Void> in
            
            do {
                try Account.sharedInstance.refreshAuthData(authData)
                return Observable.just(Void())
            } catch let error {
                return Observable.error(error)
            }
        })

        
       /* if case .Some(.Page(_,let page)) = Account.sharedInstance.loginState {
            let observable: Observable<(AuthData, DetailedUserProfile)> = APIAuthService.refreshAuthToken(params)
            
            refreshTokenObservableStore = observable.flatMap({ (authData, user) -> Observable<Void> in
                
                refreshTokenObservableStore = nil
                
                do {
                    try Account.sharedInstance.refreshUser(page, withAuthData: authData)
                    return Observable.just(Void())
                } catch let error {
                    return Observable.error(error)
                }
            })
            
        } else if case .Some(.Logged(_)) = Account.sharedInstance.loginState {
            let observable: Observable<(AuthData, DetailedUserProfile)> = APIAuthService.refreshAuthToken(params)
            
            refreshTokenObservableStore = observable.flatMap({ (authData, page) -> Observable<Void> in
                
                do {
                    try Account.sharedInstance.refreshUser(page, withAuthData: authData)
                    return Observable.just(Void())
                } catch let error {
                    return Observable.error(error)
                }
            })
        } else {
            let observable: Observable<(AuthData, GuestUser)> = APIAuthService.refreshAuthToken(params)
            
            refreshTokenObservableStore = observable.flatMap({ (authData, page) -> Observable<Void> in
                
                refreshTokenObservableStore = nil
                
                do {
                    try Account.sharedInstance.refreshUser(page, withAuthData: authData)
                    return Observable.just(Void())
                } catch let error {
                    return Observable.error(error)
                }
            })
        } */
        
        refreshTokenObservableStore?.subscribe({ (event) in
            self.isRefreshingToken = false
            switch event {
            case .Next(_): self.refreshTokenSubject.onNext(true)
            case .Error(let error):
                debugPrint(error)
            default: break
            }
        }).addDisposableTo(disposeBag)
    
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
